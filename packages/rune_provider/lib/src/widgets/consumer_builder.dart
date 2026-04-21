import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart' as p;
import 'package:rune/rune.dart';
import 'package:rune_provider/src/closure_helpers.dart';
import 'package:rune_provider/src/rune_reactive_notifier.dart';

/// Builds a `Consumer<ChangeNotifier>` that rebuilds its subtree
/// whenever the nearest provided `ChangeNotifier` notifies.
///
/// The closure signature is `(ctx, value, child) -> Widget`. What
/// `value` is depends on how the notifier exposes its state:
///
/// - **If the notifier implements [RuneReactiveNotifier]:** `value`
///   is the `state` map. Use this when the notifier's fields are
///   private and you want a flat `Map`-shaped projection. Source
///   reads as `state.count` through Rune's Map semantics.
/// - **Otherwise:** `value` is the raw notifier. Use this when the
///   host has registered member accessors via
///   `config.members.registerProperty<MyNotifier>(...)` (v1.17+).
///   Source reads as `notifier.count` through Rune's
///   `MemberRegistry` path.
///
/// The two paths coexist; one Consumer can serve both patterns
/// because `PropertyResolver` checks both surfaces in order.
///
/// Supported named arguments:
/// - `builder` (closure `(ctx, value, child) -> Widget`, required).
/// - `child` ([Widget]?) forwarded as the third arg; held constant
///   across rebuilds.
final class ConsumerBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const ConsumerBuilder();

  @override
  String get typeName => 'Consumer';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final builder = toConsumerBuilder<Object?>(
      args.named['builder'],
      widgetName: 'Consumer',
    );
    return p.Consumer<ChangeNotifier>(
      builder: (innerCtx, notifier, child) {
        final value = notifier is RuneReactiveNotifier
            ? (notifier as RuneReactiveNotifier).state
            : notifier as Object?;
        return builder(innerCtx, value, child);
      },
      child: args.get<Widget>('child'),
    );
  }
}
