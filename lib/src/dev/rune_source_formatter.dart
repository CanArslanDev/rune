import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Best-effort canonicaliser for Rune source strings.
///
/// Intended for tooling and debug workflows — not the runtime render
/// path. Takes a Rune expression (the same subset a
/// `RuneView.source` accepts) and returns a reformatted copy with:
///
/// - 2-space indentation per nesting level;
/// - each argument of a multi-line invocation on its own line;
/// - trailing comma on multi-line argument lists;
/// - the whole invocation collapsed onto one line when it fits within
///   [maxLineLength] (default `80`).
///
/// The formatter never executes or resolves the source. Unparseable
/// inputs are returned unchanged (with leading/trailing whitespace
/// trimmed) so the utility is safe to chain with other text tooling.
///
/// Lives under `src/dev/` and therefore imports no internal Rune
/// layers; it re-uses `package:analyzer` directly to parse the wrapped
/// source. This matches the architecture rule that `src/dev/` depends
/// only on Flutter and external packages.
String formatRuneSource(String source, {int maxLineLength = 80}) {
  final trimmed = _stripTrailingSemicolons(source.trim());
  if (trimmed.isEmpty) return trimmed;

  final Expression expression;
  try {
    expression = _parseExpression(trimmed);
  } on Object {
    return trimmed;
  }

  final buffer = StringBuffer();
  _writeExpression(
    expression,
    buffer: buffer,
    indent: 0,
    maxLineLength: maxLineLength,
  );
  return buffer.toString();
}

/// Strips any trailing `;` plus whitespace, returning the cleaned
/// string. Mirrors `DartParser._cleanSource` without importing it so
/// the dev layer does not reach into `src/parser/`.
String _stripTrailingSemicolons(String source) {
  var s = source;
  while (s.endsWith(';')) {
    s = s.substring(0, s.length - 1).trimRight();
  }
  return s;
}

/// Parses [source] as a Dart expression by wrapping it in a throwaway
/// top-level variable declaration, the same trick `DartParser` uses.
/// Throws when parsing fails or the wrapped declaration does not yield
/// an initializer.
Expression _parseExpression(String source) {
  final wrapped = 'dynamic __rune__ = $source;';
  final result = parseString(
    content: wrapped,
    throwIfDiagnostics: false,
  );
  if (result.errors.isNotEmpty) {
    throw FormatException(result.errors.first.message);
  }
  final decl =
      result.unit.declarations.whereType<TopLevelVariableDeclaration>().first;
  final initializer = decl.variables.variables.first.initializer;
  if (initializer == null) {
    throw const FormatException('No initializer');
  }
  return initializer;
}

/// Writes [expression] into [buffer] at the given [indent] level
/// (measured in two-space units). Dispatch follows the handful of AST
/// shapes that matter for Rune's formatter and falls back to
/// `expression.toSource()` for everything else — the formatter is a
/// canonicaliser, not a full pretty-printer.
void _writeExpression(
  Expression expression, {
  required StringBuffer buffer,
  required int indent,
  required int maxLineLength,
}) {
  if (expression is MethodInvocation) {
    _writeInvocation(
      target: expression.target,
      methodName: expression.methodName.name,
      argumentList: expression.argumentList,
      buffer: buffer,
      indent: indent,
      maxLineLength: maxLineLength,
    );
    return;
  }
  if (expression is InstanceCreationExpression) {
    final namedType = expression.constructorName.type;
    final prefix = namedType.importPrefix?.name.lexeme;
    final ctorName = expression.constructorName.name?.name;
    final String head;
    if (prefix != null) {
      head = '$prefix.${namedType.name2.lexeme}';
    } else if (ctorName != null) {
      head = '${namedType.name2.lexeme}.$ctorName';
    } else {
      head = namedType.name2.lexeme;
    }
    final keyword = expression.keyword?.lexeme;
    final prefixText = keyword == null ? '' : '$keyword ';
    _writeInvocationHead(
      head: '$prefixText$head',
      argumentList: expression.argumentList,
      buffer: buffer,
      indent: indent,
      maxLineLength: maxLineLength,
    );
    return;
  }
  if (expression is ListLiteral) {
    _writeListLiteral(
      expression,
      buffer: buffer,
      indent: indent,
      maxLineLength: maxLineLength,
    );
    return;
  }
  if (expression is SetOrMapLiteral) {
    _writeSetOrMapLiteral(
      expression,
      buffer: buffer,
      indent: indent,
      maxLineLength: maxLineLength,
    );
    return;
  }
  if (expression is ParenthesizedExpression) {
    buffer.write('(');
    _writeExpression(
      expression.expression,
      buffer: buffer,
      indent: indent,
      maxLineLength: maxLineLength,
    );
    buffer.write(')');
    return;
  }

  // Default: emit analyzer's canonical single-line form. Good enough
  // for literals, binary ops, identifiers, property accesses, and the
  // other leaf shapes the formatter does not break.
  buffer.write(expression.toSource());
}

/// Emits a bare `MethodInvocation` — `Text('hi')`, `EdgeInsets.all(16)`,
/// `items.map((x) => x)`. [target], when non-null, is prepended as
/// `target.methodName`.
void _writeInvocation({
  required Expression? target,
  required String methodName,
  required ArgumentList argumentList,
  required StringBuffer buffer,
  required int indent,
  required int maxLineLength,
}) {
  final head = target == null
      ? methodName
      : '${target.toSource()}.$methodName';
  _writeInvocationHead(
    head: head,
    argumentList: argumentList,
    buffer: buffer,
    indent: indent,
    maxLineLength: maxLineLength,
  );
}

/// Writes [head] followed by [argumentList] in either single-line or
/// multi-line layout depending on [maxLineLength].
void _writeInvocationHead({
  required String head,
  required ArgumentList argumentList,
  required StringBuffer buffer,
  required int indent,
  required int maxLineLength,
}) {
  final args = argumentList.arguments;
  if (args.isEmpty) {
    buffer
      ..write(head)
      ..write('()');
    return;
  }

  // Try a single-line emission first.
  final singleLine = _tryFormatSingleLine(
    head: head,
    arguments: args,
    closer: ')',
    opener: '(',
  );
  final currentColumn = _currentColumn(buffer, indent);
  if (singleLine != null &&
      currentColumn + singleLine.length <= maxLineLength) {
    buffer.write(singleLine);
    return;
  }

  // Multi-line layout.
  final innerIndent = indent + 1;
  final innerPad = '  ' * innerIndent;
  final outerPad = '  ' * indent;
  buffer
    ..write(head)
    ..write('(\n');
  for (final arg in args) {
    buffer.write(innerPad);
    _writeArgument(
      arg,
      buffer: buffer,
      indent: innerIndent,
      maxLineLength: maxLineLength,
    );
    buffer.write(',\n');
  }
  buffer
    ..write(outerPad)
    ..write(')');
}

/// Writes a single argument (named or positional) into [buffer].
/// Named arguments are emitted as `name: value`; nested expressions
/// recurse so a `Column(children: [...])` sees the list formatted too.
void _writeArgument(
  Expression arg, {
  required StringBuffer buffer,
  required int indent,
  required int maxLineLength,
}) {
  if (arg is NamedExpression) {
    buffer
      ..write(arg.name.label.name)
      ..write(': ');
    _writeExpression(
      arg.expression,
      buffer: buffer,
      indent: indent,
      maxLineLength: maxLineLength,
    );
    return;
  }
  _writeExpression(
    arg,
    buffer: buffer,
    indent: indent,
    maxLineLength: maxLineLength,
  );
}

/// Emits a [ListLiteral] with the same fits-in-one-line-or-break logic
/// as invocations. Multi-line form uses one element per line with a
/// trailing comma.
void _writeListLiteral(
  ListLiteral expression, {
  required StringBuffer buffer,
  required int indent,
  required int maxLineLength,
}) {
  final elements = expression.elements;
  if (elements.isEmpty) {
    buffer.write('[]');
    return;
  }

  final singleLine = _tryFormatSingleLine(
    head: '',
    arguments: elements,
    closer: ']',
    opener: '[',
  );
  final currentColumn = _currentColumn(buffer, indent);
  if (singleLine != null &&
      currentColumn + singleLine.length <= maxLineLength) {
    buffer.write(singleLine);
    return;
  }

  final innerIndent = indent + 1;
  final innerPad = '  ' * innerIndent;
  final outerPad = '  ' * indent;
  buffer.write('[\n');
  for (final element in elements) {
    buffer.write(innerPad);
    if (element is Expression) {
      _writeExpression(
        element,
        buffer: buffer,
        indent: innerIndent,
        maxLineLength: maxLineLength,
      );
    } else {
      // CollectionElement shapes (if/for/spread) — fall back to the
      // analyzer's canonical form for v1.10.0. Pretty-printing them is
      // tracked for a later iteration.
      buffer.write(element.toSource());
    }
    buffer.write(',\n');
  }
  buffer
    ..write(outerPad)
    ..write(']');
}

/// Emits a [SetOrMapLiteral] — `{1, 2, 3}` (set) or
/// `{'a': 1, 'b': 2}` (map) — with the same fits-vs-break logic as
/// [ListLiteral].
///
/// Sits as a standalone helper rather than routing through the list
/// path because:
///  - Map entries need bespoke `key: value` rendering that strips the
///    space analyzer's own `toSource()` emits before the colon.
///  - Empty `{}` defaults to a Set literal in Dart syntax; preserving
///    that verbatim is simpler than trying to infer intent.
void _writeSetOrMapLiteral(
  SetOrMapLiteral expression, {
  required StringBuffer buffer,
  required int indent,
  required int maxLineLength,
}) {
  final elements = expression.elements;
  if (elements.isEmpty) {
    buffer.write('{}');
    return;
  }

  final singleLine = _tryFormatSingleLine(
    head: '',
    arguments: elements,
    opener: '{',
    closer: '}',
  );
  final currentColumn = _currentColumn(buffer, indent);
  if (singleLine != null &&
      currentColumn + singleLine.length <= maxLineLength) {
    buffer.write(singleLine);
    return;
  }

  final innerIndent = indent + 1;
  final innerPad = '  ' * innerIndent;
  final outerPad = '  ' * indent;
  buffer.write('{\n');
  for (final element in elements) {
    buffer.write(innerPad);
    if (element is MapLiteralEntry) {
      _writeMapEntry(
        element,
        buffer: buffer,
        indent: innerIndent,
        maxLineLength: maxLineLength,
      );
    } else if (element is Expression) {
      _writeExpression(
        element,
        buffer: buffer,
        indent: innerIndent,
        maxLineLength: maxLineLength,
      );
    } else {
      buffer.write(element.toSource());
    }
    buffer.write(',\n');
  }
  buffer
    ..write(outerPad)
    ..write('}');
}

/// Writes a single map entry as `key: value`, recursing into the value
/// so nested calls get broken correctly. Analyzer's own `toSource()`
/// emits `key : value` with a space before the colon; this helper
/// normalises to the idiomatic Dart/Flutter style.
void _writeMapEntry(
  MapLiteralEntry entry, {
  required StringBuffer buffer,
  required int indent,
  required int maxLineLength,
}) {
  buffer
    ..write(entry.key.toSource())
    ..write(': ');
  _writeExpression(
    entry.value,
    buffer: buffer,
    indent: indent,
    maxLineLength: maxLineLength,
  );
}

/// Returns [head] + opener + joined `arguments.toSource()` + closer
/// when no argument introduces a newline in its own source form and
/// no element contains a multi-line substring. Otherwise returns
/// `null`, signalling the caller to emit the multi-line layout.
String? _tryFormatSingleLine({
  required String head,
  required List<AstNode> arguments,
  required String opener,
  required String closer,
}) {
  final pieces = <String>[];
  for (final arg in arguments) {
    final rendered = _renderNodeForSingleLine(arg);
    if (rendered.contains('\n')) return null;
    pieces.add(rendered);
  }
  return '$head$opener${pieces.join(', ')}$closer';
}

/// Produces the single-line form of an argument or list element.
/// Named-argument formatting is handled here so `a: b` does not gain
/// extra spaces from `toSource()`.
String _renderNodeForSingleLine(AstNode node) {
  if (node is NamedExpression) {
    return '${node.name.label.name}: ${node.expression.toSource()}';
  }
  if (node is MapLiteralEntry) {
    // Analyzer's toSource() emits `key : value` with a space before
    // the colon; normalise to idiomatic `key: value` here so short
    // maps render compactly.
    return '${node.key.toSource()}: ${node.value.toSource()}';
  }
  return node.toSource();
}

/// Returns the column the next character will land on, measured as the
/// offset from the start of the current line in [buffer]. Falls back
/// to `2 * indent` when the buffer is empty so the first line is
/// indented correctly.
int _currentColumn(StringBuffer buffer, int indent) {
  final soFar = buffer.toString();
  if (soFar.isEmpty) return indent * 2;
  final lastNewline = soFar.lastIndexOf('\n');
  if (lastNewline == -1) return soFar.length;
  return soFar.length - lastNewline - 1;
}
