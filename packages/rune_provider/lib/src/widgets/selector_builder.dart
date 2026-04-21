import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart' as p;
import 'package:rune/rune.dart';
import 'package:rune_provider/src/closure_helpers.dart';
import 'package:rune_provider/src/rune_reactive_notifier.dart';

/// Builds a `Selector<ChangeNotifier, Object?>` that only rebuilds
/// its subtree when a derived value changes.
///
/// Like `ConsumerBuilder`, the `selector` closure receives either
/// the `state` Map (for notifiers that implement
/// [RuneReactiveNotifier]) or the raw notifier itself (rely on
/// `config.members.registerProperty<MyNotifier>(...)` for
/// dot-access in that case). The two patterns coexist; pick the
/// one that fits your notifier's shape.
///
/// Supported named arguments:
/// - `selector` (closure `(ctx, value) -> Object?`, required):
///   derives the value the subtree depends on. Equality is
///   compared with `==`; return a new value only when the
///   subtree should rebuild.
/// - `builder` (closure `(ctx, value, child) -> Widget`, required):
///   invoked on first mount and whenever `selector` returns a
///   different value.
/// - `child` ([Widget]?): held constant across rebuilds; forwarded
///   to `builder` as the third argument.
final class SelectorBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const SelectorBuilder();

  @override
  String get typeName => 'Selector';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final selector = toSelectorSelector<Object?>(
      args.named['selector'],
      widgetName: 'Selector',
    );
    final builder = toConsumerBuilder<Object?>(
      args.named['builder'],
      widgetName: 'Selector',
    );
    return p.Selector<ChangeNotifier, Object?>(
      selector: (innerCtx, notifier) {
        final value = notifier is RuneReactiveNotifier
            ? (notifier as RuneReactiveNotifier).state
            : notifier as Object?;
        return selector(innerCtx, value);
      },
      builder: builder,
      child: args.get<Widget>('child'),
    );
  }
}
