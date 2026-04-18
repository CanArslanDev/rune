import 'package:rune/src/bridges/rune_bridge.dart';
import 'package:rune/src/defaults/rune_defaults.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/extension_registry.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

/// Top-level configuration handed to a `RuneView`. Bundles the widget,
/// value, and constant registries that the resolver consults during a
/// render.
///
/// Immutable by convention in Phase 1–2: registries are expected to be
/// populated at construction and left alone afterward. A later phase may
/// tighten this with a `freeze()` step.
final class RuneConfig {
  /// Creates a configuration. Each registry defaults to empty if not
  /// supplied.
  RuneConfig({
    WidgetRegistry? widgets,
    ValueRegistry? values,
    ConstantRegistry? constants,
    ExtensionRegistry? extensions,
  })  : widgets = widgets ?? WidgetRegistry(),
        values = values ?? ValueRegistry(),
        constants = constants ?? ConstantRegistry(),
        extensions = extensions ?? ExtensionRegistry();

  /// Creates a configuration with the full Phase 1-2d default builder
  /// set pre-registered via [RuneDefaults.registerAll]: Phase 1 MVP
  /// widgets, Phase 2c layout/chrome widgets, Phase 2d buttons, Phase
  /// 1-2c value builders, Phase 2a constants, and Phase 2c Icons.
  factory RuneConfig.defaults() {
    final config = RuneConfig();
    RuneDefaults.registerAll(config);
    return config;
  }

  /// Registry of widget builders consulted by `InvocationResolver`.
  final WidgetRegistry widgets;

  /// Registry of value builders consulted for non-widget constructor
  /// calls.
  final ValueRegistry values;

  /// Registry of named static constants (e.g. `Colors.red`,
  /// `MainAxisAlignment.center`).
  final ConstantRegistry constants;

  /// Registry of property-access extensions (`.w`, `.h`, `.px`, etc.)
  /// consulted by `PropertyResolver` when evaluating `PropertyAccess`
  /// expressions.
  final ExtensionRegistry extensions;

  /// Applies each bridge in [bridges] to this config in order,
  /// registering their contributions. Returns `this` so the call can
  /// chain fluently.
  ///
  /// ```dart
  /// final config = RuneConfig.defaults()
  ///     .withBridges([const MyBridge(), const OtherBridge()]);
  /// ```
  ///
  /// Duplicate registrations across bridges surface as `StateError`
  /// from the underlying registries — bridges should own disjoint
  /// namespaces.
  RuneConfig withBridges(List<RuneBridge> bridges) {
    for (final bridge in bridges) {
      bridge.registerInto(this);
    }
    return this; // ignore: avoid_returning_this
  }
}
