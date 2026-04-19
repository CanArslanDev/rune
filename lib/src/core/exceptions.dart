import 'package:rune/src/core/source_span.dart';

/// The sealed base of all Rune-originated exceptions.
///
/// Every concrete variant carries:
/// - [source]: the offending input string (either the full widget source
///   or a sub-expression's `toSource()`).
/// - [message]: a human-readable explanation.
/// - [location]: an optional [SourceSpan] pointing into the Rune source
///   where the error originates. `null` for throw sites that do not yet
///   thread location information.
sealed class RuneException implements Exception {
  /// Constructs a [RuneException] with the offending [source] and
  /// [message]. [location] is optional and defaults to `null`.
  const RuneException(this.source, this.message, {this.location});

  /// The input string that triggered the failure.
  final String source;

  /// Human-readable failure message.
  final String message;

  /// Optional pointer to where the error originates in the Rune source.
  /// Threaded through automatically by parser/resolver throw sites
  /// (Task B.2). `null` for throw sites that haven't been upgraded, for
  /// test-constructed instances, and for exceptions raised outside a
  /// known source location.
  final SourceSpan? location;

  /// Returns a formatted pointer block suitable for appending to a
  /// variant's `toString`. Produces an empty string when [location] is
  /// `null` so one-line `toString` output is preserved for throw sites
  /// that don't carry a span.
  ///
  /// Shape, when a location is present:
  ///
  /// ```
  ///
  ///   at line <L>, column <C>:
  ///     <excerpt line>
  ///     <indent>^^^
  /// ```
  ///
  /// The excerpt and caret lines come directly from
  /// [SourceSpan.toPointerString] with a 4-space indent applied so the
  /// block sits visually beneath the one-line summary.
  String _locationDetail() {
    final loc = location;
    if (loc == null) return '';
    final indented =
        loc.toPointerString().split('\n').map((l) => '    $l').join('\n');
    return '\n  at line ${loc.line}, column ${loc.column}:\n$indented';
  }
}

/// Raised when `DartParser` cannot produce an AST from the input.
final class ParseException extends RuneException {
  /// Creates a [ParseException] with the offending [source] and a [message].
  const ParseException(super.source, super.message, {super.location});

  @override
  String toString() =>
      'ParseException: $message (source: "$source")${_locationDetail()}';
}

/// Raised when the resolver encounters an expression shape it cannot handle
/// (e.g. a language construct outside Rune's supported subset).
final class ResolveException extends RuneException {
  /// Creates a [ResolveException] with the offending [source] and a [message].
  const ResolveException(super.source, super.message, {super.location});

  @override
  String toString() =>
      'ResolveException: $message (source: "$source")${_locationDetail()}';
}

/// Raised when a type referenced in the source has no registered builder.
final class UnregisteredBuilderException extends RuneException {
  /// Creates an [UnregisteredBuilderException] for the given [typeName]
  /// found at [source].
  const UnregisteredBuilderException(
    String source,
    this.typeName, {
    SourceSpan? location,
  }) : super(
          source,
          'No builder registered for type "$typeName"',
          location: location,
        );

  /// The missing type's name (e.g. `"FooWidget"`).
  final String typeName;

  @override
  String toString() =>
      'UnregisteredBuilderException: $message (source: "$source")'
      '${_locationDetail()}';
}

/// Raised when resolved arguments are missing a required value or have the
/// wrong runtime type.
final class ArgumentException extends RuneException {
  /// Creates an [ArgumentException] with the offending [source] and a
  /// [message].
  const ArgumentException(super.source, super.message, {super.location});

  @override
  String toString() =>
      'ArgumentException: $message (source: "$source")${_locationDetail()}';
}

/// Raised when data or event binding cannot be satisfied (e.g. a data key
/// the source refers to is not present in `RuneDataContext`).
final class BindingException extends RuneException {
  /// Creates a [BindingException] with the offending [source] and a [message].
  const BindingException(super.source, super.message, {super.location});

  @override
  String toString() =>
      'BindingException: $message (source: "$source")${_locationDetail()}';
}
