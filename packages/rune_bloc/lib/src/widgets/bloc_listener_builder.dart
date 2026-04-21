import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rune/rune.dart';
import 'package:rune_bloc/src/closure_helpers.dart';
import 'package:rune_bloc/src/rune_reactive_state.dart';

/// Builds a `BlocListener<BlocBase<Object?>, Object?>` that fires a
/// side-effect closure on each state change without rebuilding its
/// subtree.
///
/// Supported named arguments:
/// - `listener` (closure `(ctx, state) -> Object?`, required):
///   called on every state change. `state` is the state's
///   `toRuneMap()` projection (empty map for non-reactive states).
///   Return value is ignored.
/// - `child` ([Widget], required): rendered as-is; unchanged across
///   state transitions.
final class BlocListenerBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const BlocListenerBuilder();

  @override
  String get typeName => 'BlocListener';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final child = args.require<Widget>('child', source: 'BlocListener');
    final listener = toListener<Map<String, Object?>>(
      args.named['listener'],
      widgetName: 'BlocListener',
    );
    return BlocListener<BlocBase<Object?>, Object?>(
      listener: (innerCtx, state) {
        final projected = state is RuneReactiveState
            ? state.toRuneMap()
            : const <String, Object?>{};
        listener(innerCtx, projected);
      },
      child: child,
    );
  }
}
