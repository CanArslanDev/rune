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
}

/// Raised when `DartParser` cannot produce an AST from the input.
final class ParseException extends RuneException {
  /// Creates a [ParseException] with the offending [source] and a [message].
  const ParseException(super.source, super.message);

  @override
  String toString() => 'ParseException: $message (source: "$source")';
}

/// Raised when the resolver encounters an expression shape it cannot handle
/// (e.g. a language construct outside Rune's supported subset).
final class ResolveException extends RuneException {
  /// Creates a [ResolveException] with the offending [source] and a [message].
  const ResolveException(super.source, super.message);

  @override
  String toString() => 'ResolveException: $message (source: "$source")';
}

/// Raised when a type referenced in the source has no registered builder.
final class UnregisteredBuilderException extends RuneException {
  /// Creates an [UnregisteredBuilderException] for the given [typeName]
  /// found at [source].
  const UnregisteredBuilderException(String source, this.typeName)
      : super(source, 'No builder registered for type "$typeName"');

  /// The missing type's name (e.g. `"FooWidget"`).
  final String typeName;

  @override
  String toString() =>
      'UnregisteredBuilderException: $message (source: "$source")';
}

/// Raised when resolved arguments are missing a required value or have the
/// wrong runtime type.
final class ArgumentException extends RuneException {
  /// Creates an [ArgumentException] with the offending [source] and a
  /// [message].
  const ArgumentException(super.source, super.message);

  @override
  String toString() => 'ArgumentException: $message (source: "$source")';
}

/// Raised when data or event binding cannot be satisfied (e.g. a data key
/// the source refers to is not present in `RuneDataContext`).
final class BindingException extends RuneException {
  /// Creates a [BindingException] with the offending [source] and a [message].
  const BindingException(super.source, super.message);

  @override
  String toString() => 'BindingException: $message (source: "$source")';
}
