import 'package:rune/src/bridges/rune_bridge.dart';
import 'package:rune/src/defaults/rune_defaults.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/extension_registry.dart';
import 'package:rune/src/registry/imperative_registry.dart';
import 'package:rune/src/registry/member_registry.dart';
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
    ImperativeRegistry? imperatives,
    MemberRegistry? members,
  })  : widgets = widgets ?? WidgetRegistry(),
        values = values ?? ValueRegistry(),
        constants = constants ?? ConstantRegistry(),
        extensions = extensions ?? ExtensionRegistry(),
        imperatives = imperatives ?? ImperativeRegistry(),
        members = members ?? MemberRegistry();

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

  /// Registry of source-level imperative bridges (`showToast(...)`,
  /// `Router.go('/path')`, etc.) consulted by `InvocationResolver`
  /// before the hardcoded v1.3+ built-in bridges.
  ///
  /// Sibling bridge packages register their own imperatives here so
  /// Rune source can invoke them without a main-package update; a host
  /// that wants to shadow a built-in (e.g. swap `showDialog` for a
  /// custom implementation) can register a handler under the same name
  /// and the registry lookup wins.
  final ImperativeRegistry imperatives;

  /// Registry of user-declared properties and methods on arbitrary
  /// runtime types. Consulted by `PropertyResolver` and
  /// `InvocationResolver` AFTER the closed built-in whitelist in
  /// `builtin_members.dart` so stock types (`String`, `List`, `Map`,
  /// `ThemeData`, etc.) cannot be overridden.
  ///
  /// Use cases: exposing fields of a host-owned `ChangeNotifier`
  /// directly to source (instead of routing through a
  /// `Map`-projected `state` getter) or letting a bridge package
  /// register accessors on a third-party type without forking the
  /// main `rune` package.
  final MemberRegistry members;

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
