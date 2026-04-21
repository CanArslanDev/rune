import 'package:flutter/material.dart';
import 'package:rune/rune.dart';
import 'package:rune_http/src/rune_source_cache.dart';
import 'package:rune_http/src/rune_source_fetcher.dart';

/// Signature of the builder that renders while the first fetch
/// is in flight AND no cached copy is available.
typedef RuneHttpLoadingBuilder = Widget Function(BuildContext context);

/// Signature of the builder that renders when the fetch fails
/// AND no cached copy is available. Receives the exception so the
/// host can log it or surface a Retry button that calls
/// [RuneHttpViewState.refresh].
typedef RuneHttpErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  VoidCallback retry,
);

/// A `RuneView`-shaped widget that fetches its source from [url]
/// over HTTP and caches the response in a [RuneSourceCache].
///
/// Lifecycle in short:
///
/// 1. On first build, check the cache. If a fresh entry exists,
///    render it immediately AND kick off a background refresh.
///    If a stale entry exists, render it while the refresh is in
///    flight. If nothing is cached, show the [loading] widget.
/// 2. On a successful fetch, store the response in the cache and
///    re-render with the new source.
/// 3. On a failed fetch, keep serving whatever is cached. If
///    nothing is cached, call [onError] with the exception and
///    render [error] (or a default error view).
///
/// The cache is process-wide by default. Pass a custom
/// [RuneSourceCache] to scope differently or persist.
class RuneHttpView extends StatefulWidget {
  /// Creates a [RuneHttpView].
  const RuneHttpView({
    required this.url,
    required this.config,
    this.data,
    this.onEvent,
    this.cacheDuration = const Duration(minutes: 5),
    this.cache,
    this.fetcher,
    this.loading,
    this.error,
    this.fallback,
    this.onError,
    super.key,
  });

  /// The URL to fetch the Rune source from.
  final String url;

  /// The `RuneConfig` threaded through to the inner `RuneView`.
  final RuneConfig config;

  /// Runtime data forwarded to the inner `RuneView.data`.
  final Map<String, Object?>? data;

  /// Named-event sink forwarded to the inner `RuneView.onEvent`.
  final void Function(String event, [List<Object?>? args])? onEvent;

  /// How long a cached response stays fresh before a refresh is
  /// triggered on mount. Defaults to 5 minutes.
  final Duration cacheDuration;

  /// Optional custom cache. Defaults to a shared
  /// [InMemoryRuneSourceCache] keyed by URL.
  final RuneSourceCache? cache;

  /// Optional custom fetcher. Defaults to a
  /// [HttpRuneSourceFetcher] wrapping `package:http`.
  final RuneSourceFetcher? fetcher;

  /// Builder invoked when the first fetch is in flight AND no
  /// cached copy exists. Defaults to a centered
  /// `CircularProgressIndicator`.
  final RuneHttpLoadingBuilder? loading;

  /// Builder invoked when the fetch fails AND no cached copy
  /// exists. Defaults to a centered text error view with a Retry
  /// button.
  final RuneHttpErrorBuilder? error;

  /// Fallback widget for inner `RuneView` parse / resolve / build
  /// failures (i.e. the source was fetched but did not render).
  /// Mirrors `RuneView.fallback`.
  final Widget? fallback;

  /// Error sink forwarded to the inner `RuneView.onError` AND
  /// used for fetch failures. Fired in both cases so the host
  /// only has to wire one callback.
  final void Function(Object error, StackTrace stack)? onError;

  @override
  State<RuneHttpView> createState() => RuneHttpViewState();
}

/// Shared default cache. Visible to the package for tests.
final RuneSourceCache _defaultCache = InMemoryRuneSourceCache();

/// Shared default fetcher. Visible to the package for tests.
final RuneSourceFetcher _defaultFetcher = HttpRuneSourceFetcher();

/// Public state class so the host can call [refresh] imperatively.
class RuneHttpViewState extends State<RuneHttpView> {
  String? _currentSource;
  Object? _lastFetchError;
  bool _loading = false;

  RuneSourceCache get _cache => widget.cache ?? _defaultCache;
  RuneSourceFetcher get _fetcher => widget.fetcher ?? _defaultFetcher;

  @override
  void initState() {
    super.initState();
    _primeFromCache();
    _refreshIfNeeded();
  }

  @override
  void didUpdateWidget(RuneHttpView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _currentSource = null;
      _lastFetchError = null;
      _primeFromCache();
      _refreshIfNeeded();
    }
  }

  void _primeFromCache() {
    final entry = _cache.lookup(widget.url);
    if (entry != null) {
      _currentSource = entry.source;
    }
  }

  /// Forces a network fetch, bypassing the cache-freshness check.
  /// Used by the default error builder's Retry button and
  /// reachable from the host via a GlobalKey.
  Future<void> refresh() => _fetch(force: true);

  Future<void> _refreshIfNeeded() {
    final entry = _cache.lookup(widget.url);
    if (entry == null || !entry.isFresh(widget.cacheDuration)) {
      return _fetch(force: false);
    }
    return Future<void>.value();
  }

  Future<void> _fetch({required bool force}) async {
    if (_loading) return;
    if (!force) {
      final entry = _cache.lookup(widget.url);
      if (entry != null && entry.isFresh(widget.cacheDuration)) {
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _loading = true;
      _lastFetchError = null;
    });
    try {
      final source = await _fetcher.fetch(widget.url);
      _cache.store(
        widget.url,
        CachedRuneSource(source: source, fetchedAt: DateTime.now()),
      );
      if (!mounted) return;
      setState(() {
        _currentSource = source;
        _loading = false;
      });
    } on Object catch (e, s) {
      widget.onError?.call(e, s);
      if (!mounted) return;
      setState(() {
        _lastFetchError = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = _currentSource;
    if (source != null) {
      return RuneView(
        source: source,
        config: widget.config,
        data: widget.data,
        onEvent: widget.onEvent,
        fallback: widget.fallback,
        onError: widget.onError,
      );
    }
    if (_lastFetchError != null) {
      final errorBuilder = widget.error ?? _defaultErrorBuilder;
      return errorBuilder(context, _lastFetchError!, refresh);
    }
    final loadingBuilder = widget.loading ?? _defaultLoadingBuilder;
    return loadingBuilder(context);
  }
}

Widget _defaultLoadingBuilder(BuildContext context) {
  return const Center(child: CircularProgressIndicator());
}

Widget _defaultErrorBuilder(
  BuildContext context,
  Object error,
  VoidCallback retry,
) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load this screen',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
