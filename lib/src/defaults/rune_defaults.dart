import 'package:rune/src/builders/values/border_radius_circular_builder.dart';
import 'package:rune/src/builders/values/box_decoration_builder.dart';
import 'package:rune/src/builders/values/color_builder.dart';
import 'package:rune/src/builders/values/edge_insets_all_builder.dart';
import 'package:rune/src/builders/values/edge_insets_ltrb_builder.dart';
import 'package:rune/src/builders/values/edge_insets_only_builder.dart';
import 'package:rune/src/builders/values/edge_insets_symmetric_builder.dart';
import 'package:rune/src/builders/values/text_style_builder.dart';
import 'package:rune/src/builders/widgets/app_bar_builder.dart';
import 'package:rune/src/builders/widgets/card_builder.dart';
import 'package:rune/src/builders/widgets/center_builder.dart';
import 'package:rune/src/builders/widgets/checkbox_builder.dart';
import 'package:rune/src/builders/widgets/column_builder.dart';
import 'package:rune/src/builders/widgets/container_builder.dart';
import 'package:rune/src/builders/widgets/divider_builder.dart';
import 'package:rune/src/builders/widgets/elevated_button_builder.dart';
import 'package:rune/src/builders/widgets/expanded_builder.dart';
import 'package:rune/src/builders/widgets/flexible_builder.dart';
import 'package:rune/src/builders/widgets/icon_builder.dart';
import 'package:rune/src/builders/widgets/icon_button_builder.dart';
import 'package:rune/src/builders/widgets/image_asset_builder.dart';
import 'package:rune/src/builders/widgets/image_network_builder.dart';
import 'package:rune/src/builders/widgets/list_tile_builder.dart';
import 'package:rune/src/builders/widgets/list_view_builder.dart';
import 'package:rune/src/builders/widgets/padding_builder.dart';
import 'package:rune/src/builders/widgets/row_builder.dart';
import 'package:rune/src/builders/widgets/scaffold_builder.dart';
import 'package:rune/src/builders/widgets/sized_box_builder.dart';
import 'package:rune/src/builders/widgets/spacer_builder.dart';
import 'package:rune/src/builders/widgets/stack_builder.dart';
import 'package:rune/src/builders/widgets/switch_builder.dart';
import 'package:rune/src/builders/widgets/text_builder.dart';
import 'package:rune/src/builders/widgets/text_button_builder.dart';
import 'package:rune/src/builders/widgets/text_field_builder.dart';
import 'package:rune/src/config.dart';
import 'package:rune/src/defaults/phase_2a_constants.dart';
import 'package:rune/src/defaults/phase_2c_icons.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

/// Static helpers that register the default Rune widget, value, and
/// constant builders into a [RuneConfig] or its individual registries.
///
/// Typical use is via [RuneConfig.defaults], which delegates to
/// [registerAll]. Custom configs that want only a subset of defaults
/// (e.g. all widgets but bring-your-own colors) can cherry-pick the
/// individual `register*` methods:
///
/// ```dart
/// final config = RuneConfig();
/// RuneDefaults.registerWidgets(config.widgets);
/// // skip RuneDefaults.registerValues — use custom builders
/// RuneDefaults.registerConstants(config.constants);
/// ```
///
/// The class is `abstract final` with no instance members; all entry
/// points are static.
abstract final class RuneDefaults {
  /// Populates every registry on [config] with the complete default
  /// Phase 1–2d builder set.
  static void registerAll(RuneConfig config) {
    registerWidgets(config.widgets);
    registerValues(config.values);
    registerConstants(config.constants);
  }

  /// Registers every Phase 1–2d widget builder into [registry].
  static void registerWidgets(WidgetRegistry registry) {
    registry
      // Phase 1
      ..registerBuilder(const TextBuilder())
      ..registerBuilder(const SizedBoxBuilder())
      ..registerBuilder(const ContainerBuilder())
      ..registerBuilder(const ColumnBuilder())
      ..registerBuilder(const RowBuilder())
      // Phase 2c
      ..registerBuilder(const PaddingBuilder())
      ..registerBuilder(const CenterBuilder())
      ..registerBuilder(const StackBuilder())
      ..registerBuilder(const ExpandedBuilder())
      ..registerBuilder(const FlexibleBuilder())
      ..registerBuilder(const CardBuilder())
      ..registerBuilder(const IconBuilder())
      ..registerBuilder(const ListViewBuilder())
      ..registerBuilder(const AppBarBuilder())
      ..registerBuilder(const ScaffoldBuilder())
      // Phase 2d
      ..registerBuilder(const ElevatedButtonBuilder())
      ..registerBuilder(const TextButtonBuilder())
      ..registerBuilder(const IconButtonBuilder())
      // C.2: form inputs
      ..registerBuilder(const TextFieldBuilder())
      ..registerBuilder(const SwitchBuilder())
      ..registerBuilder(const CheckboxBuilder())
      // Layout helpers + Material tiles.
      ..registerBuilder(const ListTileBuilder())
      ..registerBuilder(const DividerBuilder())
      ..registerBuilder(const SpacerBuilder());
  }

  /// Registers every Phase 1–2c value builder into [registry].
  static void registerValues(ValueRegistry registry) {
    registry
      ..registerBuilder(const EdgeInsetsAllBuilder())
      ..registerBuilder(const EdgeInsetsSymmetricBuilder())
      ..registerBuilder(const EdgeInsetsOnlyBuilder())
      ..registerBuilder(const EdgeInsetsFromLTRBBuilder())
      ..registerBuilder(const ColorBuilder())
      ..registerBuilder(const TextStyleBuilder())
      ..registerBuilder(const BorderRadiusCircularBuilder())
      ..registerBuilder(const BoxDecorationBuilder())
      ..registerBuilder(const ImageNetworkBuilder())
      ..registerBuilder(const ImageAssetBuilder());
  }

  /// Seeds [registry] with Phase 2a constants (Colors, enums,
  /// EdgeInsets.zero, BoxShape, FlexFit) and the Phase 2c Icons subset.
  static void registerConstants(ConstantRegistry registry) {
    registerPhase2aConstants(registry);
    registerPhase2cIcons(registry);
  }
}
