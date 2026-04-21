import 'package:rune/rune.dart';
import 'package:rune_riverpod/src/widgets/provider_scope_builder.dart';
import 'package:rune_riverpod/src/widgets/riverpod_consumer_builder.dart';

/// A [RuneBridge] that registers Riverpod widgets on a [RuneConfig].
///
/// Registered widgets:
/// - `ProviderScope`: wraps a subtree in
///   `flutter_riverpod`'s `ProviderScope`. Consumers typically
///   place one at the root of a `RuneView` source that contains
///   `RiverpodConsumer` calls, OR declare it once in the host app
///   above the `RuneView` and skip it in source.
/// - `RiverpodConsumer`: watches a provider (passed in through
///   the data map) and rebuilds its subtree on change.
///   `builder(ctx, value, child)` receives the provider's current
///   value (or `.toRuneMap()` projection if the value implements
///   `RuneReactiveValue`).
///
/// Duplicate-name collisions with the main-package defaults are
/// impossible: neither type name appears in the default Rune
/// registry.
final class RiverpodBridge implements RuneBridge {
  /// Const constructor. The bridge is stateless.
  const RiverpodBridge();

  @override
  void registerInto(RuneConfig config) {
    config.widgets
      ..registerBuilder(const ProviderScopeBuilder())
      ..registerBuilder(const RiverpodConsumerBuilder());
  }
}
