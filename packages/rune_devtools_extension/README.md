# rune_devtools_extension

Flutter DevTools extension for the [`rune`](../..) package. Adds a **rune** tab to Flutter DevTools that inspects live `RuneView` instances in a running host app: their source strings, data contexts, parse-cache sizes, and last render errors.

## How it works

`rune` v1.18.0+ registers a VM service extension named `ext.rune.inspect` the first time a `RuneView` mounts (via `dart:developer.registerExtension`, which is compiled out in release builds). This package ships a Flutter web app that Flutter DevTools loads inside the **rune** tab; at debug time the app calls the service extension over the VM service protocol and renders the JSON payload as a list of expandable cards.

The extension is **read-only** in v0.1.0. You can:

- See every live `RuneView` (one card per instance).
- Copy its source string with one tap.
- Expand the data context as pretty-printed JSON.
- See the last render error (with the same caret-pointer shape `RuneException.toString()` produces).
- See the per-view parse cache size.

## Requirements

- `rune: ^1.18.0` (must be listed as a direct dependency in the host app; the service extension ships with the main package).
- Flutter SDK with DevTools support (Flutter 3.16 and newer).
- The host app must be run in **debug** or **profile** mode. Release builds strip `dart:developer.registerExtension`.

## Install

Add the extension as a dev dependency of the host app:

```yaml
dev_dependencies:
  rune_devtools_extension: ^0.1.0
```

Flutter DevTools auto-discovers the extension on the next `flutter pub get` + `flutter run`. No registration code is needed in the host.

## Using the extension

1. Run the host app: `flutter run -d chrome` (or any debug-mode target).
2. Open Flutter DevTools. The extension tab shows up as **rune**.
3. Mount at least one `RuneView` in the host app. Then tap **Refresh** on the extension's toolbar.
4. The tab lists every live `RuneView`. Tap a card to expand its source, data, cache stats, and last error.

If the extension tab reports **Could not reach the host process**, the host app most likely has no `RuneView` mounted yet (the service extension is registered lazily on the first mount) or is running in release mode. Mount a view or rerun in debug and retry.

## Building the web app

The published package ships a pre-built Flutter web bundle under `extension/devtools/build/`. When developing the extension itself (as opposed to consuming it), rebuild after each change:

```bash
cd packages/rune_devtools_extension
flutter build web --pwa-strategy=none --web-renderer canvaskit --base-href=/ --output=extension/devtools/build
```

Check the resulting bundle in, then run the host app and the updated UI loads on the next DevTools refresh.

## License

MIT. See [`LICENSE`](LICENSE).
