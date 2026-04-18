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
import 'package:rune/src/builders/widgets/column_builder.dart';
import 'package:rune/src/builders/widgets/container_builder.dart';
import 'package:rune/src/builders/widgets/expanded_builder.dart';
import 'package:rune/src/builders/widgets/flexible_builder.dart';
import 'package:rune/src/builders/widgets/icon_builder.dart';
import 'package:rune/src/builders/widgets/image_asset_builder.dart';
import 'package:rune/src/builders/widgets/image_network_builder.dart';
import 'package:rune/src/builders/widgets/list_view_builder.dart';
import 'package:rune/src/builders/widgets/padding_builder.dart';
import 'package:rune/src/builders/widgets/row_builder.dart';
import 'package:rune/src/builders/widgets/scaffold_builder.dart';
import 'package:rune/src/builders/widgets/sized_box_builder.dart';
import 'package:rune/src/builders/widgets/stack_builder.dart';
import 'package:rune/src/builders/widgets/text_builder.dart';
import 'package:rune/src/defaults/phase_2a_constants.dart';
import 'package:rune/src/defaults/phase_2c_icons.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

/// Top-level configuration handed to a [RuneView]. Bundles the widget,
/// value, and constants registries that the resolver consults during a
/// render.
///
/// Immutable by convention in Phase 1: registries are expected to be
/// populated at construction and left alone afterward. Phase 2 may tighten
/// this with a `freeze()` step.
final class RuneConfig {
  /// Creates a configuration. Each registry defaults to empty if not
  /// supplied.
  RuneConfig({
    WidgetRegistry? widgets,
    ValueRegistry? values,
    ConstantRegistry? constants,
  })  : widgets = widgets ?? WidgetRegistry(),
        values = values ?? ValueRegistry(),
        constants = constants ?? ConstantRegistry();

  /// Creates a configuration with the Phase-1 widget/value builders plus
  /// the Phase-2a constants (Colors, axis/alignment/size/fit enums,
  /// FontWeight, EdgeInsets.zero) pre-registered. Phase 2b value builders
  /// (EdgeInsets.symmetric/.only/.fromLTRB, Color, TextStyle,
  /// BorderRadius.circular, BoxDecoration) are also pre-registered.
  /// Phase 2c adds ten widget builders (Padding, Center, Stack, Expanded,
  /// Flexible, Card, Icon, ListView, AppBar, Scaffold), two Image value
  /// builders (Image.network, Image.asset), and ~60 Icons.* constants.
  factory RuneConfig.defaults() {
    final config = RuneConfig();
    config.widgets
      ..registerBuilder(const TextBuilder())
      ..registerBuilder(const SizedBoxBuilder())
      ..registerBuilder(const ContainerBuilder())
      ..registerBuilder(const ColumnBuilder())
      ..registerBuilder(const RowBuilder())
      ..registerBuilder(const PaddingBuilder())
      ..registerBuilder(const CenterBuilder())
      ..registerBuilder(const StackBuilder())
      ..registerBuilder(const ExpandedBuilder())
      ..registerBuilder(const FlexibleBuilder())
      ..registerBuilder(const CardBuilder())
      ..registerBuilder(const IconBuilder())
      ..registerBuilder(const ListViewBuilder())
      ..registerBuilder(const AppBarBuilder())
      ..registerBuilder(const ScaffoldBuilder());
    config.values
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
    registerPhase2aConstants(config.constants);
    registerPhase2cIcons(config.constants);
    return config;
  }

  /// Registry of widget builders consulted by `InvocationResolver`.
  final WidgetRegistry widgets;

  /// Registry of value builders consulted for non-widget constructor calls.
  final ValueRegistry values;

  /// Registry of named static constants consulted by `IdentifierResolver`
  /// when resolving `PrefixedIdentifier` expressions like `Colors.red`.
  final ConstantRegistry constants;
}
