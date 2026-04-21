# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-21

### Added

- First release of `rune_http`. `RuneHttpView` fetches a Rune
  source string from a URL, caches it with a configurable TTL,
  and renders through an inner `RuneView`. Unlocks the
  server-driven-UI flow: host app depends on
  `rune_http` + `rune` and mounts `RuneHttpView(url: ...)` at
  the screen root.
- **Offline-first rendering.** If a cached entry exists for the
  URL, the first frame shows it immediately; a background fetch
  runs if the entry has exceeded `cacheDuration`. When the
  network fails, the cached copy keeps serving.
- **Pluggable cache and fetcher.** `RuneSourceCache` +
  `InMemoryRuneSourceCache` (default, process-wide) and
  `RuneSourceFetcher` + `HttpRuneSourceFetcher` (default,
  `package:http`-backed) are small interfaces that hosts can
  replace for persistent caching, auth headers, or test fakes.
- **Imperative refresh** via `GlobalKey<RuneHttpViewState>()`
  and `state.refresh()`.
- 16 unit + widget tests cover `CachedRuneSource.isFresh`,
  in-memory cache round-trip + invalidation + clear, fetcher
  success/failure mapping, widget-tree happy-path rendering,
  cache-first on subsequent mount, stale-while-revalidate,
  error-view rendering with Retry, and cache-wins-when-fetch-fails.
