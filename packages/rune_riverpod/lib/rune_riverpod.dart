/// Rune Riverpod bridge.
///
/// Registers a narrow surface of
/// [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) on
/// a `RuneConfig` so Rune source can consume Riverpod-managed state
/// without leaving the declarative layer:
///
/// ```dart
/// final config = RuneConfig.defaults()
///     .withBridges(const [RiverpodBridge()]);
/// ```
///
/// Registered widgets:
/// - `ProviderScope`: wraps a subtree with
///   `flutter_riverpod`'s own `ProviderScope` (root or nested).
/// - `RiverpodConsumer`: watches a provider (passed in as a data
///   value) and rebuilds on change. `(ctx, value, child) -> Widget`.
///
/// For typed state classes the same reactive-map pattern as
/// `rune_provider` / `rune_bloc` applies: implement
/// `RuneReactiveValue` so source dot-access reaches individual
/// fields.
library rune_riverpod;

export 'src/riverpod_bridge.dart' show RiverpodBridge;
export 'src/rune_reactive_value.dart' show RuneReactiveValue;
