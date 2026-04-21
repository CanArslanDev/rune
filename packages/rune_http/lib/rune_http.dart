/// HTTP source-fetching bridge for the `rune` package.
///
/// The server-driven-UI use case rune was designed for needs an
/// answer for "how do I get the source string to the device".
/// `RuneHttpView` solves that: it fetches a Rune source string
/// from a URL, caches it in memory (per-URL, TTL-bounded), serves
/// the cached copy instantly on subsequent mounts, and falls back
/// to the last-known-good source when the network is unavailable.
///
/// ```dart
/// import 'package:rune/rune.dart';
/// import 'package:rune_http/rune_http.dart';
///
/// final config = RuneConfig.defaults();
///
/// RuneHttpView(
///   url: 'https://cms.example.com/home.rune',
///   config: config,
///   data: {'userName': 'Ali'},
///   cacheDuration: const Duration(minutes: 5),
///   onEvent: (name, [args]) => debugPrint('event: $name'),
/// )
/// ```
///
/// The cache is a process-wide in-memory map keyed by URL; pass a
/// custom `RuneSourceCache` if you want persistent or per-view
/// scoping.
library rune_http;

export 'src/rune_http_view.dart' show RuneHttpView;
export 'src/rune_source_cache.dart'
    show CachedRuneSource, InMemoryRuneSourceCache, RuneSourceCache;
export 'src/rune_source_fetcher.dart'
    show HttpRuneSourceFetcher, RuneSourceFetchException, RuneSourceFetcher;
