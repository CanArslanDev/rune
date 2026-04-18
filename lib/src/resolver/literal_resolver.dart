import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';

/// Resolves Dart AST literals to their runtime Dart values.
///
/// Phase 1 supports [IntegerLiteral], [DoubleLiteral], [BooleanLiteral],
/// [NullLiteral], and [SimpleStringLiteral]. Adjacent-string concatenation,
/// interpolation, and collection literals land in Phase 2.
final class LiteralResolver {
  /// Constructs a [LiteralResolver]. Stateless; cheap to instantiate.
  LiteralResolver();

  /// Returns the Dart value corresponding to [node]. Throws
  /// [ResolveException] for unsupported literal subtypes (e.g.
  /// [StringInterpolation], collection literals) — those land in Phase 2.
  Object? resolve(Literal node) {
    return switch (node) {
      IntegerLiteral(:final value?) => value,
      IntegerLiteral() => throw ResolveException(
          node.toSource(),
          'Integer literal overflowed its representation',
        ),
      DoubleLiteral(:final value) => value,
      BooleanLiteral(:final value) => value,
      NullLiteral() => null,
      SimpleStringLiteral(:final value) => value,
      AdjacentStrings(:final strings) =>
        strings.map((s) => (s as SimpleStringLiteral).value).join(),
      _ => throw ResolveException(
          node.toSource(),
          'Unsupported literal: ${node.runtimeType}',
        ),
    };
  }
}
