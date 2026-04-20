import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart' as p;
import 'package:rune/rune.dart';
import 'package:rune_provider/src/closure_helpers.dart';
import 'package:rune_provider/src/rune_reactive_notifier.dart';

/// Builds a `Consumer<ChangeNotifier>` that rebuilds its subtree
/// whenever the nearest provided `ChangeNotifier` notifies.
///
/// The closure receives the notifier's state as a `Map<String,
/// Object?>`, not the raw `ChangeNotifier`. Notifiers that want their
/// fields to be reachable from Rune source must implement
/// [RuneReactiveNotifier] so the bridge can extract a map snapshot
/// per rebuild. Non-reactive notifiers yield an empty map (and a
/// `ResolveException` if the closure tries to access a key).
///
/// Supported named arguments:
/// - `builder` (closure `(ctx, state, child) -> Widget`, required) -
///   called on every notification. `state` is a
///   `Map<String, Object?>` (from `notifier.state`).
/// - `child` ([Widget]?) - forwarded to `builder` as the third
///   argument; held constant across rebuilds.
final class ConsumerBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const ConsumerBuilder();

  @override
  String get typeName => 'Consumer';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final builder = toConsumerBuilder<Map<String, Object?>>(
      args.named['builder'],
      widgetName: 'Consumer',
    );
    return p.Consumer<ChangeNotifier>(
      builder: (innerCtx, notifier, child) {
        final state = (notifier is RuneReactiveNotifier)
            ? (notifier as RuneReactiveNotifier).state
            : const <String, Object?>{};
        return builder(innerCtx, state, child);
      },
      child: args.get<Widget>('child'),
    );
  }
}
