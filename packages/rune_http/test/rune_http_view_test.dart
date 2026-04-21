import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_http/rune_http.dart';

/// Scriptable fetcher for widget tests.
class _FakeFetcher implements RuneSourceFetcher {
  _FakeFetcher();

  final Map<String, List<_FakeFetchStep>> _script = {};
  final Map<String, int> _calls = {};

  void enqueueSuccess(String url, String source) {
    (_script[url] ??= []).add(_FakeFetchStep.success(source));
  }

  void enqueueFailure(String url, Object error) {
    (_script[url] ??= []).add(_FakeFetchStep.failure(error));
  }

  int callCountFor(String url) => _calls[url] ?? 0;

  @override
  Future<String> fetch(String url) async {
    _calls[url] = (_calls[url] ?? 0) + 1;
    final queue = _script[url];
    if (queue == null || queue.isEmpty) {
      throw StateError('No scripted response for $url');
    }
    final next = queue.removeAt(0);
    if (next.error != null) {
      // ignore: only_throw_errors
      throw next.error!;
    }
    return next.source!;
  }
}

class _FakeFetchStep {
  _FakeFetchStep._(this.source, this.error);
  factory _FakeFetchStep.success(String s) => _FakeFetchStep._(s, null);
  factory _FakeFetchStep.failure(Object e) => _FakeFetchStep._(null, e);

  final String? source;
  final Object? error;
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('RuneHttpView', () {
    testWidgets('renders the fetched source on the happy path',
        (tester) async {
      final fetcher = _FakeFetcher()
        ..enqueueSuccess('https://x/home', "Text('hello from cms')");
      final cache = InMemoryRuneSourceCache();

      await tester.pumpWidget(
        _wrap(
          RuneHttpView(
            url: 'https://x/home',
            config: RuneConfig.defaults(),
            fetcher: fetcher,
            cache: cache,
          ),
        ),
      );

      // First frame shows the loading indicator (cache empty, fetch
      // pending).
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let the fetch complete.
      await tester.pumpAndSettle();

      expect(find.text('hello from cms'), findsOneWidget);
      expect(fetcher.callCountFor('https://x/home'), 1);
      expect(cache.lookup('https://x/home'), isNotNull);
    });

    testWidgets('serves cached source immediately on subsequent mount',
        (tester) async {
      final cache = InMemoryRuneSourceCache()
        ..store(
          'https://x/home',
          CachedRuneSource(
            source: "Text('cached')",
            fetchedAt: DateTime.now(),
          ),
        );
      final fetcher = _FakeFetcher();

      await tester.pumpWidget(
        _wrap(
          RuneHttpView(
            url: 'https://x/home',
            config: RuneConfig.defaults(),
            cache: cache,
            fetcher: fetcher,
          ),
        ),
      );

      // Cache hit + fresh => the first frame already renders the
      // cached source, no loading indicator, no network call.
      expect(find.text('cached'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpAndSettle();
      expect(fetcher.callCountFor('https://x/home'), 0);
    });

    testWidgets(
      'refreshes in the background when the cache entry is stale',
      (tester) async {
        final stale = DateTime.now().subtract(const Duration(hours: 1));
        final cache = InMemoryRuneSourceCache()
          ..store(
            'https://x/home',
            CachedRuneSource(source: "Text('stale')", fetchedAt: stale),
          );
        final fetcher = _FakeFetcher()
          ..enqueueSuccess('https://x/home', "Text('fresh')");

        await tester.pumpWidget(
          _wrap(
            RuneHttpView(
              url: 'https://x/home',
              config: RuneConfig.defaults(),
              cache: cache,
              fetcher: fetcher,
            ),
          ),
        );

        // Stale source is served immediately.
        expect(find.text('stale'), findsOneWidget);

        // Fetch completes and replaces with fresh source.
        await tester.pumpAndSettle();
        expect(find.text('fresh'), findsOneWidget);
        expect(fetcher.callCountFor('https://x/home'), 1);
      },
    );

    testWidgets(
      'shows error builder when fetch fails and cache is empty',
      (tester) async {
        final fetcher = _FakeFetcher()
          ..enqueueFailure(
            'https://x/home',
            const RuneSourceFetchException('https://x/home', 'boom'),
          );
        Object? captured;

        await tester.pumpWidget(
          _wrap(
            RuneHttpView(
              url: 'https://x/home',
              config: RuneConfig.defaults(),
              fetcher: fetcher,
              cache: InMemoryRuneSourceCache(),
              onError: (e, _) => captured = e,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Could not load'), findsOneWidget);
        expect(find.byIcon(Icons.cloud_off), findsOneWidget);
        expect(captured, isA<RuneSourceFetchException>());
      },
    );

    testWidgets(
      'refresh button retries the fetch',
      (tester) async {
        final fetcher = _FakeFetcher()
          ..enqueueFailure(
            'https://x/home',
            const RuneSourceFetchException('https://x/home', 'boom'),
          )
          ..enqueueSuccess('https://x/home', "Text('recovered')");

        await tester.pumpWidget(
          _wrap(
            RuneHttpView(
              url: 'https://x/home',
              config: RuneConfig.defaults(),
              fetcher: fetcher,
              cache: InMemoryRuneSourceCache(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsOneWidget);
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(find.text('recovered'), findsOneWidget);
      },
    );

    testWidgets(
      'serves cached source when fetch fails',
      (tester) async {
        final cache = InMemoryRuneSourceCache()
          ..store(
            'https://x/home',
            CachedRuneSource(
              source: "Text('from-cache')",
              fetchedAt: DateTime.now().subtract(const Duration(hours: 1)),
            ),
          );
        final fetcher = _FakeFetcher()
          ..enqueueFailure(
            'https://x/home',
            const RuneSourceFetchException('https://x/home', 'offline'),
          );

        await tester.pumpWidget(
          _wrap(
            RuneHttpView(
              url: 'https://x/home',
              config: RuneConfig.defaults(),
              cache: cache,
              fetcher: fetcher,
              cacheDuration: const Duration(minutes: 1),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Cached source wins even though background refresh failed.
        expect(find.text('from-cache'), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
      },
    );
  });
}
