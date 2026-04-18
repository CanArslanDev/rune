/// Rune — responsive-sizer bridge.
///
/// Registers `.w`, `.h`, `.sp`, `.dm` property extensions on a
/// `RuneConfig` so source strings can use percent-of-screen sizing
/// and text-scale-aware fonts:
///
/// ```dart
/// SizedBox(width: 50.w)                 // 50% of screen width
/// Text('Hi', style: TextStyle(fontSize: 16.sp))
/// ```
///
/// Consumers apply the bridge via `RuneConfig.withBridges`:
///
/// ```dart
/// final config = RuneConfig.defaults()
///     .withBridges([const ResponsiveSizerBridge()]);
/// ```
library rune_responsive_sizer;

export 'src/responsive_sizer_bridge.dart' show ResponsiveSizerBridge;
