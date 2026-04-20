/// Rune Provider bridge.
///
/// Registers a curated trio of widgets from the
/// [`provider`](https://pub.dev/packages/provider) package on a
/// `RuneConfig` so Rune source can express reactive state without
/// escaping into the host app: `ChangeNotifierProvider`, `Consumer`,
/// and `Selector`.
///
/// Consumers apply the bridge via `RuneConfig.withBridges`:
///
/// ```dart
/// final config = RuneConfig.defaults()
///     .withBridges(const [ProviderBridge()]);
/// ```
///
/// The bridge is deliberately small: each `ChangeNotifierProvider`
/// scopes a single `ChangeNotifier`. Users who need multiple
/// notifiers nest providers. The type argument is fixed to
/// `ChangeNotifier` under the hood, which keeps source untyped while
/// staying compatible with the typed `Provider<T>` / `Consumer<T>`
/// APIs underneath.
library rune_provider;

export 'src/provider_bridge.dart' show ProviderBridge;
export 'src/rune_reactive_notifier.dart' show RuneReactiveNotifier;
