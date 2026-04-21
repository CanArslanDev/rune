import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rune/rune.dart';
import 'package:rune_bloc/src/closure_helpers.dart';
import 'package:rune_bloc/src/rune_reactive_state.dart';

/// Builds a `BlocBuilder<BlocBase<Object?>, Object?>` that
/// rebuilds on every state change from the nearest provided bloc.
///
/// The `builder` closure receives `(ctx, state, child)` where
/// `state` is:
/// - the result of `state.toRuneMap()` if the bloc's state
///   implements [RuneReactiveState];
/// - an empty `Map<String, Object?>` otherwise (source-side
///   dot-access falls back to Map semantics, yielding `null` for
///   missing keys).
///
/// Supported named arguments:
/// - `builder` (closure `(ctx, state, child) -> Widget`, required).
/// - `child` ([Widget]?): forwarded as the third closure arg;
///   held constant across rebuilds so the author can opt expensive
///   subtrees out of the rebuild.
final class BlocBuilderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const BlocBuilderBuilder();

  @override
  String get typeName => 'BlocBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final builder = toBuilder<Map<String, Object?>>(
      args.named['builder'],
      widgetName: 'BlocBuilder',
    );
    return BlocBuilder<BlocBase<Object?>, Object?>(
      builder: (innerCtx, state) {
        final projected = state is RuneReactiveState
            ? state.toRuneMap()
            : const <String, Object?>{};
        return builder(innerCtx, projected, args.get<Widget>('child'));
      },
    );
  }
}
