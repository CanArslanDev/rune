import 'package:rune/rune.dart';
import 'package:rune_bloc/src/widgets/bloc_builder_builder.dart';
import 'package:rune_bloc/src/widgets/bloc_listener_builder.dart';
import 'package:rune_bloc/src/widgets/bloc_provider_builder.dart';

/// A [RuneBridge] that registers the reactive BLoC-pattern trio on
/// a [RuneConfig].
///
/// Registered widgets:
/// - `BlocProvider`: exposes a `Cubit` / `Bloc` to its subtree.
///   Accepts either `create: (ctx) => MyCubit()` (auto-disposed on
///   unmount) or `value: existingCubit` (not disposed).
/// - `BlocBuilder`: rebuilds when the nearest provided
///   `BlocBase<State>`'s state changes. Builder receives
///   `(ctx, state, child)` where `state` is the state's
///   `toRuneMap()` projection (or an empty map for non-reactive
///   states).
/// - `BlocListener`: side-effect-only counterpart to `BlocBuilder`.
///   Requires a `child:` widget and fires the listener on every
///   state change; the child itself does not rebuild in response.
///
/// Duplicate-name collisions with the main-package defaults are
/// impossible: none of the three type names appear in the default
/// Rune registry.
final class BlocBridge implements RuneBridge {
  /// Const constructor. The bridge is stateless.
  const BlocBridge();

  @override
  void registerInto(RuneConfig config) {
    config.widgets
      ..registerBuilder(const BlocProviderBuilder())
      ..registerBuilder(const BlocBuilderBuilder())
      ..registerBuilder(const BlocListenerBuilder());
  }
}
