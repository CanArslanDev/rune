/// Rune BLoC bridge.
///
/// Registers a focused subset of [flutter_bloc](https://pub.dev/packages/flutter_bloc)
/// on a `RuneConfig` so Rune source can consume the BLoC pattern
/// in a way that mirrors `rune_provider`'s ChangeNotifier flow:
///
/// ```dart
/// final config = RuneConfig.defaults()
///     .withBridges(const [BlocBridge()]);
/// ```
///
/// Registered widgets:
/// - `BlocProvider`: exposes a `Cubit` / `Bloc` to its subtree.
/// - `BlocBuilder`: rebuilds when the state changes, with a
///   `(ctx, state, child) -> Widget` closure. `state` is projected
///   as a `Map<String, Object?>` via `RuneReactiveState` so dot-
///   access (`state.count`) works through Rune's property
///   resolver.
/// - `BlocListener`: fires side-effects on state change without
///   rebuilding; the `listener` closure receives the same Map.
library rune_bloc;

export 'src/bloc_bridge.dart' show BlocBridge;
export 'src/rune_reactive_state.dart' show RuneReactiveState;
