import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/constants/cupertino_icons.dart';
import 'package:rune_cupertino/src/values/cupertino_theme_data_builder.dart';
import 'package:rune_cupertino/src/widgets/cupertino_activity_indicator_builder.dart';
import 'package:rune_cupertino/src/widgets/cupertino_alert_dialog_builder.dart';
import 'package:rune_cupertino/src/widgets/cupertino_app_builder.dart';
import 'package:rune_cupertino/src/widgets/cupertino_button_builder.dart';
import 'package:rune_cupertino/src/widgets/cupertino_dialog_action_builder.dart';
import 'package:rune_cupertino/src/widgets/cupertino_navigation_bar_builder.dart';
import 'package:rune_cupertino/src/widgets/cupertino_page_scaffold_builder.dart';
import 'package:rune_cupertino/src/widgets/cupertino_slider_builder.dart';
import 'package:rune_cupertino/src/widgets/cupertino_switch_builder.dart';
import 'package:rune_cupertino/src/widgets/cupertino_text_field_builder.dart';

/// A [RuneBridge] that registers a curated subset of Flutter's
/// Cupertino widget set, the `CupertinoThemeData` value builder, and a
/// selection of `CupertinoIcons` constants on a [RuneConfig].
///
/// Registered widgets:
/// `CupertinoApp`, `CupertinoPageScaffold`, `CupertinoNavigationBar`,
/// `CupertinoButton`, `CupertinoSwitch`, `CupertinoSlider`,
/// `CupertinoTextField`, `CupertinoActivityIndicator`,
/// `CupertinoAlertDialog`, `CupertinoDialogAction`.
///
/// Registered values: `CupertinoThemeData`.
///
/// Registered constants: 30 common `CupertinoIcons.*` entries.
///
/// Usage:
///
/// ```dart
/// final config = RuneConfig.defaults()
///     .withBridges(const [CupertinoBridge()]);
/// ```
///
/// Duplicate names across bridges surface as `StateError` from the
/// underlying registries; consumers that stack the Material default
/// set with this bridge face no collisions because every type name
/// registered here is `Cupertino`-prefixed.
final class CupertinoBridge implements RuneBridge {
  /// Const constructor. The bridge is stateless.
  const CupertinoBridge();

  @override
  void registerInto(RuneConfig config) {
    config.widgets
      ..registerBuilder(const CupertinoAppBuilder())
      ..registerBuilder(const CupertinoPageScaffoldBuilder())
      ..registerBuilder(const CupertinoNavigationBarBuilder())
      ..registerBuilder(const CupertinoButtonBuilder())
      ..registerBuilder(const CupertinoSwitchBuilder())
      ..registerBuilder(const CupertinoSliderBuilder())
      ..registerBuilder(const CupertinoTextFieldBuilder())
      ..registerBuilder(const CupertinoActivityIndicatorBuilder())
      ..registerBuilder(const CupertinoAlertDialogBuilder())
      ..registerBuilder(const CupertinoDialogActionBuilder());
    config.values.registerBuilder(const CupertinoThemeDataBuilder());
    registerCupertinoIcons(config.constants);
  }
}
