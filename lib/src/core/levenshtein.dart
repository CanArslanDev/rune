/// Lightweight Levenshtein-distance utilities used by resolver throw
/// sites to propose "did you mean ...?" suggestions.
///
/// The helpers are pure Dart, with no Flutter dependency. They live in
/// `src/core/` so every resolver and exception factory can import them
/// without violating the architecture import-flow invariants.
library;

import 'dart:math' as math;

/// Computes the Levenshtein edit distance between [a] and [b].
///
/// The distance is the minimum number of single-character insertions,
/// deletions, or substitutions needed to transform [a] into [b]. Returns
/// `0` iff the strings are equal. Uses the standard two-row dynamic
/// programming implementation for `O(min(|a|, |b|))` memory.
int levenshteinDistance(String a, String b) {
  if (identical(a, b)) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  // Ensure the shorter string is `b` so the working rows are small.
  final String shorter;
  final String longer;
  if (a.length <= b.length) {
    shorter = a;
    longer = b;
  } else {
    shorter = b;
    longer = a;
  }

  final shortLen = shorter.length;
  final longLen = longer.length;

  var previous = List<int>.generate(shortLen + 1, (i) => i);
  var current = List<int>.filled(shortLen + 1, 0);

  for (var i = 1; i <= longLen; i++) {
    current[0] = i;
    final longCodeUnit = longer.codeUnitAt(i - 1);
    for (var j = 1; j <= shortLen; j++) {
      final cost = shorter.codeUnitAt(j - 1) == longCodeUnit ? 0 : 1;
      final deletion = previous[j] + 1;
      final insertion = current[j - 1] + 1;
      final substitution = previous[j - 1] + cost;
      current[j] = math.min(math.min(deletion, insertion), substitution);
    }
    // Swap rows.
    final tmp = previous;
    previous = current;
    current = tmp;
  }

  return previous[shortLen];
}

/// Returns the entry in [known] with the smallest Levenshtein distance
/// to [candidate], provided that distance is strictly less than
/// [maxDistance] + 1.
///
/// Returns `null` when [known] is empty or when no entry falls within
/// the threshold. Ties are broken in iteration order of [known]: the
/// first hit wins.
///
/// The default [maxDistance] of `3` catches common typos
/// (`Colums` → `Column`, `toUppercase` → `toUpperCase`) without
/// surfacing unhelpful suggestions on totally unrelated names.
String? findNearestName(
  String candidate,
  Iterable<String> known, {
  int maxDistance = 3,
}) {
  String? best;
  var bestDistance = maxDistance + 1;
  for (final name in known) {
    if (name == candidate) {
      // Exact match is never a useful suggestion — if the caller is
      // asking for a suggestion, the original candidate was rejected
      // elsewhere for a reason unrelated to spelling. Skip silently.
      continue;
    }
    final d = levenshteinDistance(candidate, name);
    if (d < bestDistance) {
      bestDistance = d;
      best = name;
    }
  }
  return best;
}
