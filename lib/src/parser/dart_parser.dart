import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';

/// Wraps `package:analyzer`'s `parseString` to turn a raw Dart expression
/// string into an [Expression] AST node.
///
/// The raw input is wrapped as `dynamic __rune__ = $source;` so the analyzer
/// can treat it as a well-formed top-level variable declaration. The
/// initializer of that declaration is then returned as the parsed
/// expression.
final class DartParser {
  /// Constructs a [DartParser]. Stateless; instances are cheap.
  DartParser();

  /// Parses [source] and returns its AST root as an [Expression].
  ///
  /// Throws [ParseException] on empty input, syntactically invalid input,
  /// or any unexpected analyzer structure.
  Expression parse(String source) {
    final cleaned = _cleanSource(source);
    if (cleaned.isEmpty) {
      throw ParseException(source, 'Source is empty after trimming');
    }

    final wrapped = 'dynamic __rune__ = $cleaned;';

    final ParseStringResult result;
    try {
      result = parseString(
        content: wrapped,
        throwIfDiagnostics: false,
      );
    } catch (e) {
      throw ParseException(source, 'Analyzer raised: $e');
    }

    if (result.errors.isNotEmpty) {
      throw ParseException(source, result.errors.first.message);
    }

    final declarations = result.unit.declarations;
    if (declarations.length != 1 ||
        declarations.first is! TopLevelVariableDeclaration) {
      throw ParseException(
        source,
        'Expected a single TopLevelVariableDeclaration; '
        'got ${declarations.length} declarations.',
      );
    }

    final decl = declarations.first as TopLevelVariableDeclaration;
    if (decl.variables.variables.length != 1) {
      throw ParseException(source, 'Expected exactly one variable in wrapper');
    }
    final initializer = decl.variables.variables.first.initializer;
    if (initializer == null) {
      throw ParseException(source, 'Wrapped variable had no initializer');
    }
    return initializer;
  }

  /// Trims surrounding whitespace and strips any trailing semicolons from
  /// [source], returning the cleaned string.
  static String _cleanSource(String source) {
    var s = source.trim();
    while (s.endsWith(';')) {
      s = s.substring(0, s.length - 1).trimRight();
    }
    return s;
  }
}
