/// The sealed base of all Rune-originated exceptions.
///
/// Every concrete variant carries:
/// - [source]: the offending input string (either the full widget source
///   or a sub-expression's `toSource()`).
/// - [message]: a human-readable explanation.
sealed class RuneException implements Exception {
  const RuneException(this.source, this.message);

  /// The input string that triggered the failure.
  final String source;

  /// Human-readable failure message.
  final String message;

  @override
  String toString() => '$runtimeType: $message (source: "$source")';
}

/// Raised when `DartParser` cannot produce an AST from the input.
final class ParseException extends RuneException {
  const ParseException(super.source, super.message);
}

/// Raised when the resolver encounters an expression shape it cannot handle
/// (e.g. a language construct outside Rune's supported subset).
final class ResolveException extends RuneException {
  const ResolveException(super.source, super.message);
}

/// Raised when a type referenced in the source has no registered builder.
final class UnregisteredBuilderException extends RuneException {
  const UnregisteredBuilderException(String source, this.typeName)
      : super(source, 'No builder registered for type "$typeName"');

  /// The missing type's name (e.g. `"FooWidget"`).
  final String typeName;
}

/// Raised when resolved arguments are missing a required value or have the
/// wrong runtime type.
final class ArgumentException extends RuneException {
  const ArgumentException(super.source, super.message);
}

/// Raised when data or event binding cannot be satisfied (e.g. a data key
/// the source refers to is not present in `RuneDataContext`).
final class BindingException extends RuneException {
  const BindingException(super.source, super.message);
}
