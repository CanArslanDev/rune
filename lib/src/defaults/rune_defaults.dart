import 'package:rune/src/builders/values/border_radius_circular_builder.dart';
import 'package:rune/src/builders/values/bottom_navigation_bar_item_builder.dart';
import 'package:rune/src/builders/values/box_constraints_builder.dart';
import 'package:rune/src/builders/values/box_decoration_builder.dart';
import 'package:rune/src/builders/values/color_builder.dart';
import 'package:rune/src/builders/values/duration_builder.dart';
import 'package:rune/src/builders/values/edge_insets_all_builder.dart';
import 'package:rune/src/builders/values/edge_insets_ltrb_builder.dart';
import 'package:rune/src/builders/values/edge_insets_only_builder.dart';
import 'package:rune/src/builders/values/edge_insets_symmetric_builder.dart';
import 'package:rune/src/builders/values/grid_view_count_builder.dart';
import 'package:rune/src/builders/values/grid_view_extent_builder.dart';
import 'package:rune/src/builders/values/navigation_destination_builder.dart';
import 'package:rune/src/builders/values/navigation_rail_destination_builder.dart';
import 'package:rune/src/builders/values/offset_builder.dart';
import 'package:rune/src/builders/values/sliver_grid_count_builder.dart';
import 'package:rune/src/builders/values/sliver_grid_extent_builder.dart';
import 'package:rune/src/builders/values/text_style_builder.dart';
import 'package:rune/src/builders/values/transform_flip_builder.dart';
import 'package:rune/src/builders/values/transform_rotate_builder.dart';
import 'package:rune/src/builders/values/transform_scale_builder.dart';
import 'package:rune/src/builders/values/transform_translate_builder.dart';
import 'package:rune/src/builders/widgets/animated_container_builder.dart';
import 'package:rune/src/builders/widgets/animated_cross_fade_builder.dart';
import 'package:rune/src/builders/widgets/animated_opacity_builder.dart';
import 'package:rune/src/builders/widgets/animated_positioned_builder.dart';
import 'package:rune/src/builders/widgets/animated_size_builder.dart';
import 'package:rune/src/builders/widgets/animated_switcher_builder.dart';
import 'package:rune/src/builders/widgets/app_bar_builder.dart';
import 'package:rune/src/builders/widgets/aspect_ratio_builder.dart';
import 'package:rune/src/builders/widgets/badge_builder.dart';
import 'package:rune/src/builders/widgets/bottom_navigation_bar_builder.dart';
import 'package:rune/src/builders/widgets/card_builder.dart';
import 'package:rune/src/builders/widgets/center_builder.dart';
import 'package:rune/src/builders/widgets/checkbox_builder.dart';
import 'package:rune/src/builders/widgets/checkbox_list_tile_builder.dart';
import 'package:rune/src/builders/widgets/chip_builder.dart';
import 'package:rune/src/builders/widgets/circular_progress_indicator_builder.dart';
import 'package:rune/src/builders/widgets/clip_oval_builder.dart';
import 'package:rune/src/builders/widgets/clip_rrect_builder.dart';
import 'package:rune/src/builders/widgets/colored_box_builder.dart';
import 'package:rune/src/builders/widgets/column_builder.dart';
import 'package:rune/src/builders/widgets/constrained_box_builder.dart';
import 'package:rune/src/builders/widgets/container_builder.dart';
import 'package:rune/src/builders/widgets/custom_scroll_view_builder.dart';
import 'package:rune/src/builders/widgets/decorated_box_builder.dart';
import 'package:rune/src/builders/widgets/divider_builder.dart';
import 'package:rune/src/builders/widgets/drawer_builder.dart';
import 'package:rune/src/builders/widgets/dropdown_button_builder.dart';
import 'package:rune/src/builders/widgets/dropdown_menu_item_builder.dart';
import 'package:rune/src/builders/widgets/elevated_button_builder.dart';
import 'package:rune/src/builders/widgets/expanded_builder.dart';
import 'package:rune/src/builders/widgets/fitted_box_builder.dart';
import 'package:rune/src/builders/widgets/flexible_builder.dart';
import 'package:rune/src/builders/widgets/floating_action_button_builder.dart';
import 'package:rune/src/builders/widgets/fractionally_sized_box_builder.dart';
import 'package:rune/src/builders/widgets/gesture_detector_builder.dart';
import 'package:rune/src/builders/widgets/hero_builder.dart';
import 'package:rune/src/builders/widgets/icon_builder.dart';
import 'package:rune/src/builders/widgets/icon_button_builder.dart';
import 'package:rune/src/builders/widgets/image_asset_builder.dart';
import 'package:rune/src/builders/widgets/image_network_builder.dart';
import 'package:rune/src/builders/widgets/ink_well_builder.dart';
import 'package:rune/src/builders/widgets/limited_box_builder.dart';
import 'package:rune/src/builders/widgets/linear_progress_indicator_builder.dart';
import 'package:rune/src/builders/widgets/list_tile_builder.dart';
import 'package:rune/src/builders/widgets/list_view_builder.dart';
import 'package:rune/src/builders/widgets/navigation_bar_builder.dart';
import 'package:rune/src/builders/widgets/navigation_rail_builder.dart';
import 'package:rune/src/builders/widgets/offstage_builder.dart';
import 'package:rune/src/builders/widgets/opacity_builder.dart';
import 'package:rune/src/builders/widgets/padding_builder.dart';
import 'package:rune/src/builders/widgets/positioned_builder.dart';
import 'package:rune/src/builders/widgets/radio_builder.dart';
import 'package:rune/src/builders/widgets/radio_list_tile_builder.dart';
import 'package:rune/src/builders/widgets/row_builder.dart';
import 'package:rune/src/builders/widgets/safe_area_builder.dart';
import 'package:rune/src/builders/widgets/scaffold_builder.dart';
import 'package:rune/src/builders/widgets/semantics_builder.dart';
import 'package:rune/src/builders/widgets/single_child_scroll_view_builder.dart';
import 'package:rune/src/builders/widgets/sized_box_builder.dart';
import 'package:rune/src/builders/widgets/slider_builder.dart';
import 'package:rune/src/builders/widgets/sliver_app_bar_builder.dart';
import 'package:rune/src/builders/widgets/sliver_fill_remaining_builder.dart';
import 'package:rune/src/builders/widgets/sliver_list_builder.dart';
import 'package:rune/src/builders/widgets/sliver_padding_builder.dart';
import 'package:rune/src/builders/widgets/sliver_to_box_adapter_builder.dart';
import 'package:rune/src/builders/widgets/spacer_builder.dart';
import 'package:rune/src/builders/widgets/stack_builder.dart';
import 'package:rune/src/builders/widgets/switch_builder.dart';
import 'package:rune/src/builders/widgets/switch_list_tile_builder.dart';
import 'package:rune/src/builders/widgets/tab_bar_builder.dart';
import 'package:rune/src/builders/widgets/tab_builder.dart';
import 'package:rune/src/builders/widgets/text_builder.dart';
import 'package:rune/src/builders/widgets/text_button_builder.dart';
import 'package:rune/src/builders/widgets/text_field_builder.dart';
import 'package:rune/src/builders/widgets/tooltip_builder.dart';
import 'package:rune/src/builders/widgets/unconstrained_box_builder.dart';
import 'package:rune/src/builders/widgets/visibility_builder.dart';
import 'package:rune/src/builders/widgets/wrap_builder.dart';
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
      // Form inputs (extended).
      ..registerBuilder(const SliderBuilder())
      ..registerBuilder(const RadioBuilder())
      // Form input tiles.
      ..registerBuilder(const CheckboxListTileBuilder())
      ..registerBuilder(const SwitchListTileBuilder())
      ..registerBuilder(const RadioListTileBuilder())
      // Layout helpers + Material tiles.
      ..registerBuilder(const ListTileBuilder())
      ..registerBuilder(const DividerBuilder())
      ..registerBuilder(const SpacerBuilder())
      // Gesture handlers.
      ..registerBuilder(const GestureDetectorBuilder())
      ..registerBuilder(const InkWellBuilder())
      // Layout + scroll helpers.
      ..registerBuilder(const SingleChildScrollViewBuilder())
      ..registerBuilder(const WrapBuilder())
      ..registerBuilder(const AspectRatioBuilder())
      ..registerBuilder(const PositionedBuilder())
      // Animated widgets.
      ..registerBuilder(const AnimatedContainerBuilder())
      ..registerBuilder(const AnimatedOpacityBuilder())
      ..registerBuilder(const AnimatedPositionedBuilder())
      ..registerBuilder(const HeroBuilder())
      ..registerBuilder(const AnimatedSwitcherBuilder())
      ..registerBuilder(const AnimatedCrossFadeBuilder())
      ..registerBuilder(const AnimatedSizeBuilder())
      // Navigation.
      ..registerBuilder(const BottomNavigationBarBuilder())
      ..registerBuilder(const TabBarBuilder())
      ..registerBuilder(const TabBuilder())
      // Material 3 navigation.
      ..registerBuilder(const NavigationBarBuilder())
      ..registerBuilder(const NavigationRailBuilder())
      // Dropdown.
      ..registerBuilder(const DropdownButtonBuilder())
      ..registerBuilder(const DropdownMenuItemBuilder())
      // Material widgets — misc.
      ..registerBuilder(const FloatingActionButtonBuilder())
      ..registerBuilder(const ChipBuilder())
      ..registerBuilder(const BadgeBuilder())
      ..registerBuilder(const CircularProgressIndicatorBuilder())
      ..registerBuilder(const LinearProgressIndicatorBuilder())
      // Wrapper + utility widgets.
      ..registerBuilder(const DrawerBuilder())
      ..registerBuilder(const SafeAreaBuilder())
      ..registerBuilder(const VisibilityBuilder())
      ..registerBuilder(const OpacityBuilder())
      ..registerBuilder(const ClipRRectBuilder())
      ..registerBuilder(const ClipOvalBuilder())
      ..registerBuilder(const TooltipBuilder())
      // Slivers.
      ..registerBuilder(const CustomScrollViewBuilder())
      ..registerBuilder(const SliverListBuilder())
      ..registerBuilder(const SliverToBoxAdapterBuilder())
      ..registerBuilder(const SliverAppBarBuilder())
      ..registerBuilder(const SliverPaddingBuilder())
      ..registerBuilder(const SliverFillRemainingBuilder())
      // Display wrappers.
      ..registerBuilder(const FittedBoxBuilder())
      ..registerBuilder(const ColoredBoxBuilder())
      ..registerBuilder(const DecoratedBoxBuilder())
      ..registerBuilder(const OffstageBuilder())
      ..registerBuilder(const SemanticsBuilder())
      // Sizing primitives.
      ..registerBuilder(const ConstrainedBoxBuilder())
      ..registerBuilder(const LimitedBoxBuilder())
      ..registerBuilder(const UnconstrainedBoxBuilder())
      ..registerBuilder(const FractionallySizedBoxBuilder());
  }

  /// Registers every Phase 1–2c value builder into [registry].
  static void registerValues(ValueRegistry registry) {
    registry
      ..registerBuilder(const EdgeInsetsAllBuilder())
      ..registerBuilder(const EdgeInsetsSymmetricBuilder())
      ..registerBuilder(const EdgeInsetsOnlyBuilder())
      ..registerBuilder(const EdgeInsetsFromLTRBBuilder())
      // Layout constraints.
      ..registerBuilder(const BoxConstraintsBuilder())
      ..registerBuilder(const ColorBuilder())
      ..registerBuilder(const TextStyleBuilder())
      ..registerBuilder(const BorderRadiusCircularBuilder())
      ..registerBuilder(const BoxDecorationBuilder())
      ..registerBuilder(const ImageNetworkBuilder())
      ..registerBuilder(const ImageAssetBuilder())
      ..registerBuilder(const DurationBuilder())
      ..registerBuilder(const BottomNavigationBarItemBuilder())
      // Material 3 navigation destinations.
      ..registerBuilder(const NavigationDestinationBuilder())
      ..registerBuilder(const NavigationRailDestinationBuilder())
      // Grid views (GridView.builder needs closure syntax — deferred).
      ..registerBuilder(const GridViewCountBuilder())
      ..registerBuilder(const GridViewExtentBuilder())
      // Slivers (grid variants).
      ..registerBuilder(const SliverGridCountBuilder())
      ..registerBuilder(const SliverGridExtentBuilder())
      // Transforms.
      ..registerBuilder(const OffsetBuilder())
      ..registerBuilder(const TransformScaleBuilder())
      ..registerBuilder(const TransformRotateBuilder())
      ..registerBuilder(const TransformTranslateBuilder())
      ..registerBuilder(const TransformFlipBuilder());
  }

  /// Seeds [registry] with Phase 2a constants (Colors, enums,
  /// EdgeInsets.zero, BoxShape, FlexFit) and the Phase 2c Icons subset.
  static void registerConstants(ConstantRegistry registry) {
    registerPhase2aConstants(registry);
    registerPhase2cIcons(registry);
  }
}
