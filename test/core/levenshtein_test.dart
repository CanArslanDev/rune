import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/levenshtein.dart';

void main() {
  group('levenshteinDistance', () {
    test('returns 0 for identical strings', () {
      expect(levenshteinDistance('hello', 'hello'), 0);
    });

    test('returns source length when target is empty', () {
      expect(levenshteinDistance('Column', ''), 6);
    });

    test('returns target length when source is empty', () {
      expect(levenshteinDistance('', 'Column'), 6);
    });

    test('single substitution is distance 1', () {
      expect(levenshteinDistance('Colums', 'Column'), 1);
    });

    test('single transposition is distance 2', () {
      // 'toUpeprCase' vs 'toUpperCase': two char diffs (p→p is same, 'e'
      // and 'p' swap). Levenshtein counts swap as two ops.
      expect(levenshteinDistance('toUpeprCase', 'toUpperCase'), 2);
    });

    test('is symmetric', () {
      expect(
        levenshteinDistance('Colums', 'Column'),
        levenshteinDistance('Column', 'Colums'),
      );
    });

    test('uses two-row DP correctly on longer inputs', () {
      // kitten → sitting: canonical Wagner-Fischer example, distance 3.
      expect(levenshteinDistance('kitten', 'sitting'), 3);
    });
  });

  group('findNearestName', () {
    test('returns null when known is empty', () {
      expect(findNearestName('Colums', const <String>[]), isNull);
    });

    test('finds a one-off match within threshold', () {
      expect(
        findNearestName('Colums', const ['Row', 'Column', 'Center']),
        'Column',
      );
    });

    test('returns null when no candidate is within maxDistance', () {
      expect(
        findNearestName('zzzzz', const ['Column', 'Row']),
        isNull,
      );
    });

    test('ties break in iteration order (first hit wins)', () {
      // 'ab' vs 'ac' and 'ab' vs 'ad' — both distance 1; first wins.
      expect(
        findNearestName('ab', const ['ac', 'ad']),
        'ac',
      );
    });

    test('skips exact match (not a useful suggestion)', () {
      // If the exact token appears in `known`, skip it and return the
      // next-best. Here, 'Column' is in known AND is the candidate, so
      // 'Row' becomes the nearest (within default maxDistance=3).
      final hit = findNearestName(
        'Column',
        const ['Column', 'Row'],
      );
      // 'Column' → 'Row' has distance 6, so returns null (default
      // maxDistance=3). Confirms the skip does happen without a
      // fallback.
      expect(hit, isNull);
    });

    test('respects maxDistance of 0 (exact match only)', () {
      // maxDistance 0 means bestDistance threshold is 1 — only distance
      // 0 qualifies. Since we skip exact matches, nothing matches.
      expect(
        findNearestName('foo', const ['foo', 'bar'], maxDistance: 0),
        isNull,
      );
    });
  });
}
