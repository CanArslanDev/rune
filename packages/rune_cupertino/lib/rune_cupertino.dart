/// Rune Cupertino bridge.
///
/// Applies a curated subset of Flutter's Cupertino (iOS-style) widget set
/// to a `RuneConfig` so source strings can construct Cupertino widgets,
/// a `CupertinoThemeData` value, and reference `CupertinoIcons.*`
/// constants.
///
/// Registered widgets: `CupertinoApp`, `CupertinoPageScaffold`,
/// `CupertinoNavigationBar`, `CupertinoButton`, `CupertinoSwitch`,
/// `CupertinoSlider`, `CupertinoTextField`, `CupertinoActivityIndicator`,
/// `CupertinoAlertDialog`, `CupertinoDialogAction`.
///
/// Registered values: `CupertinoThemeData`.
///
/// Registered constants: `CupertinoIcons.*` (30 common icons).
///
/// Consumers apply the bridge via `RuneConfig.withBridges`:
///
/// ```dart
/// final config = RuneConfig.defaults()
///     .withBridges(const [CupertinoBridge()]);
/// ```
library rune_cupertino;

export 'src/cupertino_bridge.dart' show CupertinoBridge;
