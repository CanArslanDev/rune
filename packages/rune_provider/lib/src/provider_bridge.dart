import 'package:rune/rune.dart';
import 'package:rune_provider/src/widgets/change_notifier_provider_builder.dart';
import 'package:rune_provider/src/widgets/consumer_builder.dart';
import 'package:rune_provider/src/widgets/selector_builder.dart';

/// A [RuneBridge] that registers the reactive subset of
/// `package:provider` on a [RuneConfig].
///
/// Registered widgets:
/// - `ChangeNotifierProvider` - provides a `ChangeNotifier` to its
///   subtree; accepts either `create: () => notifier` or
///   `value: existingNotifier`.
/// - `Consumer` - rebuilds when the nearest provided `ChangeNotifier`
///   notifies; passes `(context, notifier, child)` to its `builder`
///   closure.
/// - `Selector` - rebuilds only when a derived value changes, which
///   reduces unnecessary subtree rebuilds compared to `Consumer`.
///
/// Duplicate-name collisions with the main-package default widget set
/// are impossible because none of the three type names appear in the
/// default Rune registry.
final class ProviderBridge implements RuneBridge {
  /// Const constructor. The bridge is stateless.
  const ProviderBridge();

  @override
  void registerInto(RuneConfig config) {
    config.widgets
      ..registerBuilder(const ChangeNotifierProviderBuilder())
      ..registerBuilder(const ConsumerBuilder())
      ..registerBuilder(const SelectorBuilder());
  }
}
