# rune_http

HTTP source-fetching bridge for the [`rune`](../..) package. `RuneHttpView` fetches a Rune source string from a URL, caches it in memory, and renders through `RuneView` with offline-first fallbacks. Unlocks the server-driven-UI use case `rune` was designed for.

## What it does

- Fetches a `RuneView.source` string from an HTTP endpoint.
- Caches each response in a process-wide in-memory map keyed by URL, with a configurable TTL (default: 5 minutes).
- On subsequent mounts, serves the cached copy instantly AND triggers a background refresh if the entry is stale.
- On fetch failure, keeps serving the last-known-good cached copy. Shows a Retry-button error view only when no cached copy exists.

## Install

```yaml
dependencies:
  rune: ^1.18.0
  rune_http: ^0.1.0
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:rune/rune.dart';
import 'package:rune_http/rune_http.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: RuneHttpView(
          url: 'https://cms.example.com/home.rune',
          config: RuneConfig.defaults(),
          data: const {'userName': 'Ali'},
          cacheDuration: const Duration(minutes: 10),
          onEvent: (name, [args]) => debugPrint('event: $name'),
          onError: (error, stack) => debugPrint('rune_http: $error'),
        ),
      ),
    ),
  );
}
```

The URL should return a valid Rune source expression as its body (same string you would hand to `RuneView.source`). Response content-type does not matter; the fetcher treats the whole body as UTF-8 text.

## Advanced

### Custom cache (persistent, database-backed, etc.)

Implement `RuneSourceCache` and pass it via the `cache:` parameter:

```dart
class SharedPrefsCache implements RuneSourceCache {
  @override
  CachedRuneSource? lookup(String url) { ... }
  @override
  void store(String url, CachedRuneSource entry) { ... }
  @override
  void invalidate(String url) { ... }
  @override
  void clear() { ... }
}

RuneHttpView(
  url: ...,
  config: ...,
  cache: SharedPrefsCache(),
)
```

### Custom fetcher (auth headers, mock, etc.)

Implement `RuneSourceFetcher` and pass it via `fetcher:`:

```dart
class AuthFetcher implements RuneSourceFetcher {
  final String token;
  AuthFetcher(this.token);

  @override
  Future<String> fetch(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw RuneSourceFetchException(url, 'HTTP ${response.statusCode}');
    }
    return response.body;
  }
}
```

### Force refresh from the host

Grab a `GlobalKey<RuneHttpViewState>` and call `refresh()`:

```dart
final key = GlobalKey<RuneHttpViewState>();

RuneHttpView(key: key, url: ..., config: ...);

ElevatedButton(
  onPressed: () => key.currentState?.refresh(),
  child: const Text('Refresh'),
)
```

## Error handling

`RuneHttpView` fires `onError` in two cases:

1. **Fetch failure** (network / protocol), wrapped in `RuneSourceFetchException`. If no cached copy is available, the default error view renders with a Retry button. If a cached copy exists, the cache wins and no error surface is shown.
2. **Source-level failure** (parse / resolve / build of the fetched source). Same exception types as `RuneView`'s `onError` callback.

`fallback:` is forwarded to the inner `RuneView` and applies to case 2 only. Case 1 is handled by the `error:` builder.

## License

MIT. See [`LICENSE`](LICENSE).
