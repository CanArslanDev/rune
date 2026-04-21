/// Categories of problem a Rune source validator may surface.
enum RuneLintIssueKind {
  /// The source did not parse as a Dart expression at all.
  parseError,

  /// A widget / value / constant referenced in source is not
  /// registered in the supplied `RuneConfig`.
  unregistered,

  /// A required builder argument was missing or malformed.
  invalidArgument,

  /// The source referenced a data identifier that is not present
  /// in the supplied `data` map.
  missingBinding,

  /// A resolver-level failure the validator could not categorise
  /// more precisely.
  resolveError,
}

/// A single issue detected by `validateRuneSource`.
class RuneLintIssue {
  /// Creates an issue record.
  const RuneLintIssue({
    required this.kind,
    required this.message,
    this.offendingSource,
    this.line,
    this.column,
  });

  /// High-level category; useful for test reporting and
  /// programmatic filtering.
  final RuneLintIssueKind kind;

  /// Human-readable description, sourced from the underlying
  /// `RuneException`.
  final String message;

  /// The substring of the Rune source that triggered the issue,
  /// when the underlying exception carries one.
  final String? offendingSource;

  /// 1-based line number within the source string, when
  /// available.
  final int? line;

  /// 1-based column number, when available.
  final int? column;

  @override
  String toString() {
    if (line == null) return '[${kind.name}] $message';
    final col = column == null ? '' : ', col $column';
    return '[${kind.name}] $message (line $line$col)';
  }
}
