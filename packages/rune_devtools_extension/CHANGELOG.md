# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-20

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
