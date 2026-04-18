import 'package:rune/src/config.dart';

/// The contract a third-party Rune extension package implements.
///
/// A bridge is a small class (often in a separate `pub` package) that
/// bundles a cohesive set of widget builders, value builders,
/// constants, and/or extension handlers. Users opt in by passing an
/// instance to `RuneConfig.withBridges`:
///
/// ```dart
/// final config = RuneConfig.defaults().withBridges([
///   const ResponsiveSizerBridge(),
///   const MyAppButtonsBridge(),
/// ]);
/// ```
///
/// The bridge is handed the target config and registers its
/// contributions via `config.widgets.registerBuilder(...)`,
/// `config.constants.register(...)`, `config.extensions.register(...)`,
/// etc. The bridge MUST be idempotent-safe only in the sense that
/// registering the same bridge twice will throw duplicate-registration
/// errors from the underlying registries — `withBridges` should not be
/// called twice with overlapping bridges.
// ignore: one_member_abstracts
abstract interface class RuneBridge {
  /// Registers this bridge's contributions into [config].
  void registerInto(RuneConfig config);
}
