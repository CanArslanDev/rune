# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-21

### Added

- `web/` Flutter-web source scaffold (`index.html`,
  `manifest.json`, `favicon.png`, maskable icons) so
  `flutter build web` can compile the DevTools UI against it.
  Tracked in git and published to pub.dev.
- `tool/build_bundle.sh` convenience script that runs
  `flutter pub get` + `flutter build web` into
  `extension/devtools/build/` and strips `.symbols` debug
  sidecars. Used by maintainers before `dart pub publish` and by
  path-dep consumers after cloning.
- `.pubignore` at the package root. Takes precedence over
  `.gitignore` during publish and deliberately omits
  `extension/devtools/build/`. The compiled bundle stays out of
  git (it is ~30 MB of derived artefacts) but lands inside the
  pub.dev archive on each release so Flutter DevTools can render
  the tab without any consumer-side build step. The same file
  also excludes `test/`, `tool/`, and `web/` from the published
  archive: unit tests, the bundle-rebuild script, and the
  Flutter-web source scaffold are maintainer-only artefacts that
  add no value to consumers and would just inflate every
  download.

## [0.1.0-scaffold] - 2026-04-20

### Added

- First release of `rune_devtools_extension`. Registers a **rune**
  tab inside Flutter DevTools that inspects live `RuneView`
  instances from a host app running in debug or profile mode.
- The extension calls `ext.rune.inspect` on the host isolate over
  the VM service protocol. `rune` >= 1.18.0 registers that
  extension lazily on the first `RuneView` mount. Payload shape:
  `{"views": [{"id", "source", "data", "cacheSize", "lastError"}]}`.
- UI is a list of expandable cards, one per live view:
  - Source string (selectable, monospace).
  - Data context pretty-printed as JSON.
  - Parse-cache size.
  - Last render error (surfaces `RuneException` caret pointers).
  - Snapshot-builder errors isolated per view.
- Read-only: no write-back in v0.1.0. Future versions may add
  source hot-edit and a historical error log.
- 7 unit tests on the wire-format parser cover happy-path,
  missing fields, stringly-typed `id` coercion, non-Map `data`,
  `cacheSize` num-to-int coercion, and error-field pass-through.

### Notes

- The package ships a pre-built Flutter web app under
  `extension/devtools/build/`. Run `flutter build web` per the
  README to regenerate after modifying the extension source.
- Release builds of the host app pay zero cost because
  `dart:developer.registerExtension` is compiled out.
