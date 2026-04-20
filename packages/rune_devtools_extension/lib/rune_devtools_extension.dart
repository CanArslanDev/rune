/// Rune Flutter DevTools extension.
///
/// When a host Flutter app depends on both `rune` (>= 1.18.0) and this
/// package, Flutter DevTools surfaces an extra tab labelled "rune"
/// that lets developers inspect every live `RuneView` instance: its
/// source string, data context, parse-cache size, and the last
/// `RuneException` if the view is currently in a fallback state.
///
/// This package exports no Dart API; its value is the compiled
/// Flutter web app under `extension/devtools/build/` that DevTools
/// loads into an iframe at debug time. The app fetches state from
/// the host process via the `ext.rune.inspect` VM service extension
/// that `rune` registers lazily in `lib/src/binding/rune_inspector.dart`.
///
/// See the package README for build and consumption instructions.
library rune_devtools_extension;
