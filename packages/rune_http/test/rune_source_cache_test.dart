import 'package:flutter_test/flutter_test.dart';
import 'package:rune_http/rune_http.dart';

void main() {
  group('CachedRuneSource.isFresh', () {
    test('returns true when age is below maxAge', () {
      final fetched = DateTime(2026, 4, 21, 12);
      final now = fetched.add(const Duration(minutes: 3));
      const entry = _Entry(source: 's', year: 2026, month: 4, day: 21);
      expect(
        entry.withFetchedAt(fetched).isFresh(
              const Duration(minutes: 5),
              now: now,
            ),
        isTrue,
      );
    });

    test('returns false when age equals maxAge', () {
      final fetched = DateTime(2026, 4, 21, 12);
      final now = fetched.add(const Duration(minutes: 5));
      const entry = _Entry(source: 's', year: 2026, month: 4, day: 21);
      expect(
        entry.withFetchedAt(fetched).isFresh(
              const Duration(minutes: 5),
              now: now,
            ),
        isFalse,
      );
    });

    test('returns false when age exceeds maxAge', () {
      final fetched = DateTime(2026, 4, 21, 12);
      final now = fetched.add(const Duration(minutes: 6));
      const entry = _Entry(source: 's', year: 2026, month: 4, day: 21);
      expect(
        entry.withFetchedAt(fetched).isFresh(
              const Duration(minutes: 5),
              now: now,
            ),
        isFalse,
      );
    });
  });

  group('InMemoryRuneSourceCache', () {
    test('starts empty', () {
      expect(InMemoryRuneSourceCache().size, 0);
    });

    test('store / lookup round-trip', () {
      final cache = InMemoryRuneSourceCache();
      final entry = CachedRuneSource(
        source: "Text('a')",
        fetchedAt: DateTime(2026, 4, 21),
      );
      cache.store('https://x/a', entry);
      expect(cache.lookup('https://x/a'), same(entry));
    });

    test('lookup returns null for absent URL', () {
      expect(InMemoryRuneSourceCache().lookup('https://x/missing'), isNull);
    });

    test('store overwrites previous entry for the same URL', () {
      final cache = InMemoryRuneSourceCache()
        ..store(
          'https://x/a',
          CachedRuneSource(source: 'v1', fetchedAt: DateTime(2026, 4, 21)),
        )
        ..store(
          'https://x/a',
          CachedRuneSource(source: 'v2', fetchedAt: DateTime(2026, 4, 22)),
        );
      expect(cache.lookup('https://x/a')!.source, 'v2');
    });

    test('invalidate removes the entry for the URL', () {
      final cache = InMemoryRuneSourceCache()
        ..store(
          'https://x/a',
          CachedRuneSource(source: 'v1', fetchedAt: DateTime(2026, 4, 21)),
        )
        ..invalidate('https://x/a');
      expect(cache.lookup('https://x/a'), isNull);
    });

    test('invalidate on absent URL is a no-op', () {
      final cache = InMemoryRuneSourceCache();
      expect(() => cache.invalidate('https://x/absent'), returnsNormally);
    });

    test('clear empties all entries', () {
      final cache = InMemoryRuneSourceCache()
        ..store(
          'https://x/a',
          CachedRuneSource(source: 'a', fetchedAt: DateTime(2026, 4, 21)),
        )
        ..store(
          'https://x/b',
          CachedRuneSource(source: 'b', fetchedAt: DateTime(2026, 4, 21)),
        );
      expect(cache.size, 2);
      cache.clear();
      expect(cache.size, 0);
    });
  });
}

class _Entry {
  const _Entry({
    required this.source,
    required this.year,
    required this.month,
    required this.day,
  });

  final String source;
  final int year;
  final int month;
  final int day;

  CachedRuneSource withFetchedAt(DateTime t) =>
      CachedRuneSource(source: source, fetchedAt: t);
}
