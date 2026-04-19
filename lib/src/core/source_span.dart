import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// A pointer into the offending Rune source string.
///
/// All coordinates are grapheme-insensitive code-unit counts matching
/// analyzer's `offset`. [offset] and [length] are 0-based; [line] and
/// [column] are 1-based (first character of the source is at
/// line 1, column 1). [excerpt] is the single source line containing
/// [offset] (without the trailing newline), useful for rendering a
/// caret-pointer diagnostic via [toPointerString].
@immutable
final class SourceSpan {
  /// Constructs a [SourceSpan].
  ///
  /// [offset] and [length] are 0-based counts into the original source;
  /// [line] and [column] are 1-based. [excerpt] is the full line of
  /// source containing [offset], without a trailing newline.
  const SourceSpan({
    required this.offset,
    required this.length,
    required this.line,
    required this.column,
    required this.excerpt,
  });

  /// Builds a [SourceSpan] from an analyzer-reported AST offset and length
  /// that refer to the wrapped source (`'dynamic __rune__ = <cleaned>;'`).
  ///
  /// Rebases [astOffset] into the user-visible [source] by subtracting the
  /// wrapper prefix length, then clamps into `[0, source.length]` so the
  /// common EOF-shaped diagnostic (analyzer reports one past end when the
  /// last token is unclosed) still produces a usable span at the end of
  /// the source. When [source] is empty (unit-test contexts that don't
  /// care about diagnostics) returns a zero-length span at the origin.
  ///
  /// This is the single source of truth for AST-offset → [SourceSpan]
  /// conversion. Both `DartParser` and the resolver layer use it.
  factory SourceSpan.fromAstOffset(
    String source,
    int astOffset,
    int astLength,
  ) {
    const wrapperPrefixLength = 19; // 'dynamic __rune__ = '.length

    if (source.isEmpty) {
      return SourceSpan.fromOffset('', 0, 0);
    }
    final rebased = astOffset - wrapperPrefixLength;
    if (rebased < 0) {
      // AST offset preceded the wrapper prefix — shouldn't happen in
      // real parses; defensive fallback for pathological inputs.
      return SourceSpan.fromOffset(source, 0, 0);
    }
    // Analyzer can report offsets one past [source.length] (EOF-shaped
    // diagnostics land on the wrapper's trailing `;`). Clamp so the span
    // points at the end of user input rather than failing.
    final clampedOffset = rebased > source.length ? source.length : rebased;
    final maxLength = source.length - clampedOffset;
    final clampedLength = astLength > maxLength ? maxLength : astLength;
    return SourceSpan.fromOffset(source, clampedOffset, clampedLength);
  }

  /// Computes a [SourceSpan] from [source] at [offset] covering [length]
  /// code units.
  ///
  /// [line] and [column] are derived by scanning [source] up to [offset]
  /// and counting `\n` occurrences. [excerpt] is the single line of
  /// [source] that contains [offset], stripped of the trailing newline.
  ///
  /// Throws [RangeError] if [offset] is negative or greater than
  /// `source.length`, or if [length] is negative.
  factory SourceSpan.fromOffset(String source, int offset, int length) {
    if (offset < 0 || offset > source.length) {
      throw RangeError.range(offset, 0, source.length, 'offset');
    }
    if (length < 0) {
      throw RangeError.range(length, 0, null, 'length');
    }

    var line = 1;
    var lastNewlineIndex = -1;
    for (var i = 0; i < offset; i++) {
      if (source.codeUnitAt(i) == 0x0A /* \n */) {
        line += 1;
        lastNewlineIndex = i;
      }
    }
    final column = offset - lastNewlineIndex;

    final excerptStart = lastNewlineIndex + 1;
    var excerptEnd = source.length;
    for (var i = excerptStart; i < source.length; i++) {
      if (source.codeUnitAt(i) == 0x0A /* \n */) {
        excerptEnd = i;
        break;
      }
    }
    final excerpt = source.substring(excerptStart, excerptEnd);

    return SourceSpan(
      offset: offset,
      length: length,
      line: line,
      column: column,
      excerpt: excerpt,
    );
  }

  /// The 0-based offset into the original source where the span begins.
  final int offset;

  /// The number of code units covered by this span (may be 0).
  final int length;

  /// The 1-based line number of [offset] within the original source.
  final int line;

  /// The 1-based column number of [offset] within [line].
  final int column;

  /// The single line of source text containing [offset], with no
  /// trailing newline.
  final String excerpt;

  /// Renders a two-line pointer suitable for inclusion in exception
  /// messages.
  ///
  /// The first line is [excerpt]; the second line is `(column - 1)`
  /// spaces followed by a run of `^` characters whose length equals
  /// [length] (minimum 1), clamped so the caret run never extends past
  /// the end of [excerpt].
  ///
  /// Example:
  ///
  /// ```
  /// Text(123)
  /// ^^^^
  /// ```
  String toPointerString() {
    final columnIndex = column - 1;
    final tailLength = math.max(0, excerpt.length - columnIndex);
    final desired = math.max(length, 1);
    final caretCount = math.max(1, math.min(desired, tailLength));
    final carets = '^' * caretCount;
    final indent = ' ' * columnIndex;
    return '$excerpt\n$indent$carets';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SourceSpan &&
        other.offset == offset &&
        other.length == length &&
        other.line == line &&
        other.column == column &&
        other.excerpt == excerpt;
  }

  @override
  int get hashCode => Object.hash(offset, length, line, column, excerpt);

  @override
  String toString() =>
      'SourceSpan(L$line:C$column, offset=$offset, length=$length)';
}
