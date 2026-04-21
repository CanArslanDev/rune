import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rune/rune.dart';
import 'package:rune_riverpod/src/closure_helpers.dart';
import 'package:rune_riverpod/src/rune_reactive_value.dart';

/// Builds a `flutter_riverpod` `Consumer` that watches a provider
/// (passed in via data) and rebuilds on state change.
///
/// Supported named arguments:
/// - `provider` ([ProviderListenable]<Object?>, required):
///   the provider to watch. Typically a `Provider<T>`,
///   `StateProvider<T>`, or `NotifierProvider<N, T>` read from
///   `data:`.
/// - `builder` (closure `(ctx, value, child) -> Widget`, required):
///   called with the provider's current value. If the value
///   implements [RuneReactiveValue], the builder receives its
///   `toRuneMap()` projection; otherwise the builder receives the
///   raw value.
/// - `child` ([Widget]?): forwarded to `builder` as the third
///   argument; held constant across rebuilds so expensive subtrees
///   can opt out of rebuild.
final class RiverpodConsumerBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const RiverpodConsumerBuilder();

  @override
  String get typeName => 'RiverpodConsumer';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final provider = args.require<ProviderListenable<Object?>>(
      'provider',
      source: 'RiverpodConsumer',
    );
    final builder = toBuilder<Object?>(
      args.named['builder'],
      widgetName: 'RiverpodConsumer',
    );
    final child = args.get<Widget>('child');
    return Consumer(
      builder: (innerCtx, ref, innerChild) {
        final value = ref.watch(provider);
        final projected =
            value is RuneReactiveValue ? value.toRuneMap() : value;
        return builder(innerCtx, projected, innerChild);
      },
      child: child,
    );
  }
}
