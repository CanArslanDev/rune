import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart' as p;
import 'package:rune/rune.dart';
import 'package:rune_provider/src/closure_helpers.dart';
import 'package:rune_provider/src/rune_reactive_notifier.dart';

/// Builds a `Selector<ChangeNotifier, Object?>` that only rebuilds
/// its subtree when a derived value changes.
///
/// Like `ConsumerBuilder`, the `selector` closure receives the
/// notifier's state as a `Map<String, Object?>` (from
/// [RuneReactiveNotifier.state]) so dot-access inside the closure
/// works. Non-reactive notifiers yield an empty map.
///
/// Supported named arguments:
/// - `selector` (closure `(ctx, state) -> Object?`, required) -
///   derives the value the subtree depends on. Equality is compared
///   with `==`; return a new value only when the subtree should
///   rebuild.
/// - `builder` (closure `(ctx, value, child) -> Widget`, required) -
///   invoked on first mount and whenever `selector` returns a
///   different value.
/// - `child` ([Widget]?) - held constant across rebuilds; forwarded
///   to `builder` as the third argument.
final class SelectorBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const SelectorBuilder();

  @override
  String get typeName => 'Selector';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final selector = toSelectorSelector<Map<String, Object?>>(
      args.named['selector'],
      widgetName: 'Selector',
    );
    final builder = toConsumerBuilder<Object?>(
      args.named['builder'],
      widgetName: 'Selector',
    );
    return p.Selector<ChangeNotifier, Object?>(
      selector: (innerCtx, notifier) {
        final state = (notifier is RuneReactiveNotifier)
            ? (notifier as RuneReactiveNotifier).state
            : const <String, Object?>{};
        return selector(innerCtx, state);
      },
      builder: builder,
      child: args.get<Widget>('child'),
    );
  }
}
