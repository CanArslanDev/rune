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

The compiled Flutter web bundle lives under `extension/devtools/build/`. It is **not tracked in git**: the output is ~30 MB of derived artefacts that have no place in source history. Instead, the bundle is produced on demand:

- **For consumers installing from pub.dev:** no action required. pub.dev publishes the bundle inside the package archive on each release, so `dart pub get` populates `extension/devtools/build/` inside the cached package directly. Flutter DevTools picks it up.
- **For consumers installing from a path-dependency (local monorepo development, git fork, etc.):** run the build once after cloning:

    ```bash
    packages/rune_devtools_extension/tool/build_bundle.sh
    ```

    The script does `flutter pub get` + `flutter build web` + strips the debug `.symbols` sidecars. Rerun whenever you edit `lib/main.dart`.

- **For maintainers of this package before publishing:** run `tool/build_bundle.sh`, then `dart pub publish`. A `.pubignore` at the package root takes precedence over `.gitignore` during publish and deliberately omits `extension/devtools/build/`, so the freshly built bundle is included in the pub.dev archive even though git never tracks it.

The local CanvasKit bundle (~20 MB) cannot be replaced by a CDN fetch because Flutter DevTools serves the extension from a local scheme with a strict CSP that blocks external origins.

## License

MIT. See [`LICENSE`](LICENSE).
