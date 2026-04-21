/// A single cached source payload.
class CachedRuneSource {
  /// Creates a cache entry holding [source] fetched at [fetchedAt].
  const CachedRuneSource({
    required this.source,
    required this.fetchedAt,
  });

  /// The raw source string returned by the origin.
  final String source;

  /// When the source was fetched from the origin. Used to decide
  /// whether the cache entry is still inside its TTL window.
  final DateTime fetchedAt;

  /// Whether this entry is still fresh given a TTL of [maxAge]
  /// against [now] (`DateTime.now()` by default).
  bool isFresh(Duration maxAge, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return reference.difference(fetchedAt) < maxAge;
  }
}

/// Pluggable cache for Rune source strings.
///
/// Implementations decide how entries are persisted. The bundled
/// [InMemoryRuneSourceCache] keeps a process-wide map; host apps
/// that need disk / database persistence can supply their own
/// implementation by wiring a [RuneSourceCache] subtype into
/// `RuneHttpView(cache: ...)`.
abstract interface class RuneSourceCache {
  /// Retrieves the cached entry for [url], or `null` if none
  /// exists. Callers apply TTL via [CachedRuneSource.isFresh].
  CachedRuneSource? lookup(String url);

  /// Stores [entry] under [url], overwriting any previous value.
  void store(String url, CachedRuneSource entry);

  /// Removes the cached entry for [url] if present. No-op when
  /// absent. Useful on forced invalidation.
  void invalidate(String url);

  /// Empties the cache.
  void clear();
}

/// In-memory implementation of [RuneSourceCache]. Process-wide
/// by default.
final class InMemoryRuneSourceCache implements RuneSourceCache {
  /// Creates an empty in-memory cache.
  InMemoryRuneSourceCache();

  final Map<String, CachedRuneSource> _entries =
      <String, CachedRuneSource>{};

  @override
  CachedRuneSource? lookup(String url) => _entries[url];

  @override
  void store(String url, CachedRuneSource entry) {
    _entries[url] = entry;
  }

  @override
  void invalidate(String url) {
    _entries.remove(url);
  }

  @override
  void clear() {
    _entries.clear();
  }

  /// Number of cached entries. Useful in tests and diagnostics.
  int get size => _entries.length;
}
