import 'package:rune/src/builders/values/animation_controller_builder.dart';
import 'package:rune/src/builders/values/border_radius_circular_builder.dart';
import 'package:rune/src/builders/values/bottom_navigation_bar_item_builder.dart';
import 'package:rune/src/builders/values/box_constraints_builder.dart';
import 'package:rune/src/builders/values/box_decoration_builder.dart';
import 'package:rune/src/builders/values/button_segment_builder.dart';
import 'package:rune/src/builders/values/color_builder.dart';
import 'package:rune/src/builders/values/color_scheme_from_seed_builder.dart';
import 'package:rune/src/builders/values/color_tween_builder.dart';
import 'package:rune/src/builders/values/cupertino_page_route_builder.dart';
import 'package:rune/src/builders/values/curved_animation_builder.dart';
import 'package:rune/src/builders/values/data_cell_builder.dart';
import 'package:rune/src/builders/values/data_column_builder.dart';
import 'package:rune/src/builders/values/data_row_builder.dart';
import 'package:rune/src/builders/values/date_time_builder.dart';
import 'package:rune/src/builders/values/duration_builder.dart';
import 'package:rune/src/builders/values/edge_insets_all_builder.dart';
import 'package:rune/src/builders/values/edge_insets_ltrb_builder.dart';
import 'package:rune/src/builders/values/edge_insets_only_builder.dart';
import 'package:rune/src/builders/values/edge_insets_symmetric_builder.dart';
import 'package:rune/src/builders/values/expansion_panel_builder.dart';
import 'package:rune/src/builders/values/filled_button_tonal_builder.dart';
import 'package:rune/src/builders/values/focus_node_builder.dart';
import 'package:rune/src/builders/values/grid_view_count_builder.dart';
import 'package:rune/src/builders/values/grid_view_count_builder_builder.dart';
import 'package:rune/src/builders/values/grid_view_extent_builder.dart';
import 'package:rune/src/builders/values/grid_view_extent_builder_builder.dart';
import 'package:rune/src/builders/values/list_view_builder_builder.dart';
import 'package:rune/src/builders/values/material_page_route_builder.dart';
import 'package:rune/src/builders/values/navigation_destination_builder.dart';
import 'package:rune/src/builders/values/navigation_rail_destination_builder.dart';
import 'package:rune/src/builders/values/offset_builder.dart';
import 'package:rune/src/builders/values/page_controller_builder.dart';
import 'package:rune/src/builders/values/page_route_builder_builder.dart';
import 'package:rune/src/builders/values/relative_rect_builder.dart';
import 'package:rune/src/builders/values/route_settings_builder.dart';
import 'package:rune/src/builders/values/rune_component_builder.dart';
import 'package:rune/src/builders/values/rune_data_table_source_builder.dart';
import 'package:rune/src/builders/values/scroll_controller_builder.dart';
import 'package:rune/src/builders/values/search_anchor_bar_builder.dart';
import 'package:rune/src/builders/values/sliver_grid_count_builder.dart';
import 'package:rune/src/builders/values/sliver_grid_count_builder_builder.dart';
import 'package:rune/src/builders/values/sliver_grid_extent_builder.dart';
import 'package:rune/src/builders/values/sliver_grid_extent_builder_builder.dart';
import 'package:rune/src/builders/values/sliver_list_builder_builder.dart';
import 'package:rune/src/builders/values/snack_bar_action_builder.dart';
import 'package:rune/src/builders/values/snack_bar_builder.dart';
import 'package:rune/src/builders/values/step_builder.dart';
import 'package:rune/src/builders/values/text_editing_controller_builder.dart';
import 'package:rune/src/builders/values/text_style_builder.dart';
import 'package:rune/src/builders/values/theme_data_builder.dart';
import 'package:rune/src/builders/values/time_of_day_builder.dart';
import 'package:rune/src/builders/values/transform_flip_builder.dart';
import 'package:rune/src/builders/values/transform_rotate_builder.dart';
import 'package:rune/src/builders/values/transform_scale_builder.dart';
import 'package:rune/src/builders/values/transform_translate_builder.dart';
import 'package:rune/src/builders/values/tween_builder.dart';
import 'package:rune/src/builders/values/value_key_builder.dart';
import 'package:rune/src/builders/widgets/alert_dialog_builder.dart';
import 'package:rune/src/builders/widgets/animated_builder_builder.dart';
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
import 'package:rune/src/builders/widgets/bottom_sheet_builder.dart';
import 'package:rune/src/builders/widgets/card_builder.dart';
import 'package:rune/src/builders/widgets/center_builder.dart';
import 'package:rune/src/builders/widgets/checkbox_builder.dart';
import 'package:rune/src/builders/widgets/checkbox_list_tile_builder.dart';
import 'package:rune/src/builders/widgets/checked_popup_menu_item_builder.dart';
import 'package:rune/src/builders/widgets/chip_builder.dart';
import 'package:rune/src/builders/widgets/choice_chip_builder.dart';
import 'package:rune/src/builders/widgets/circular_progress_indicator_builder.dart';
import 'package:rune/src/builders/widgets/clip_oval_builder.dart';
import 'package:rune/src/builders/widgets/clip_rrect_builder.dart';
import 'package:rune/src/builders/widgets/colored_box_builder.dart';
import 'package:rune/src/builders/widgets/column_builder.dart';
import 'package:rune/src/builders/widgets/constrained_box_builder.dart';
import 'package:rune/src/builders/widgets/container_builder.dart';
import 'package:rune/src/builders/widgets/custom_scroll_view_builder.dart';
import 'package:rune/src/builders/widgets/data_table_builder.dart';
import 'package:rune/src/builders/widgets/decorated_box_builder.dart';
import 'package:rune/src/builders/widgets/dialog_builder.dart';
import 'package:rune/src/builders/widgets/dismissible_builder.dart';
import 'package:rune/src/builders/widgets/divider_builder.dart';
import 'package:rune/src/builders/widgets/drag_target_builder.dart';
import 'package:rune/src/builders/widgets/draggable_builder.dart';
import 'package:rune/src/builders/widgets/drawer_builder.dart';
import 'package:rune/src/builders/widgets/dropdown_button_builder.dart';
import 'package:rune/src/builders/widgets/dropdown_menu_item_builder.dart';
import 'package:rune/src/builders/widgets/elevated_button_builder.dart';
import 'package:rune/src/builders/widgets/expanded_builder.dart';
import 'package:rune/src/builders/widgets/expansion_panel_list_builder.dart';
import 'package:rune/src/builders/widgets/expansion_tile_builder.dart';
import 'package:rune/src/builders/widgets/fade_transition_builder.dart';
import 'package:rune/src/builders/widgets/filled_button_builder.dart';
import 'package:rune/src/builders/widgets/filter_chip_builder.dart';
import 'package:rune/src/builders/widgets/fitted_box_builder.dart';
import 'package:rune/src/builders/widgets/flexible_builder.dart';
import 'package:rune/src/builders/widgets/floating_action_button_builder.dart';
import 'package:rune/src/builders/widgets/focus_builder.dart';
import 'package:rune/src/builders/widgets/focus_scope_builder.dart';
import 'package:rune/src/builders/widgets/form_builder.dart';
import 'package:rune/src/builders/widgets/fractionally_sized_box_builder.dart';
import 'package:rune/src/builders/widgets/future_builder_builder.dart';
import 'package:rune/src/builders/widgets/gesture_detector_builder.dart';
import 'package:rune/src/builders/widgets/hero_builder.dart';
import 'package:rune/src/builders/widgets/icon_builder.dart';
import 'package:rune/src/builders/widgets/icon_button_builder.dart';
import 'package:rune/src/builders/widgets/image_asset_builder.dart';
import 'package:rune/src/builders/widgets/image_network_builder.dart';
import 'package:rune/src/builders/widgets/ink_well_builder.dart';
import 'package:rune/src/builders/widgets/interactive_viewer_builder.dart';
import 'package:rune/src/builders/widgets/layout_builder_builder.dart';
import 'package:rune/src/builders/widgets/limited_box_builder.dart';
import 'package:rune/src/builders/widgets/linear_progress_indicator_builder.dart';
import 'package:rune/src/builders/widgets/list_tile_builder.dart';
import 'package:rune/src/builders/widgets/list_view_builder.dart';
import 'package:rune/src/builders/widgets/listenable_builder_builder.dart';
import 'package:rune/src/builders/widgets/long_press_draggable_builder.dart';
import 'package:rune/src/builders/widgets/navigation_bar_builder.dart';
import 'package:rune/src/builders/widgets/navigation_rail_builder.dart';
import 'package:rune/src/builders/widgets/offstage_builder.dart';
import 'package:rune/src/builders/widgets/opacity_builder.dart';
import 'package:rune/src/builders/widgets/orientation_builder_builder.dart';
import 'package:rune/src/builders/widgets/outlined_button_builder.dart';
import 'package:rune/src/builders/widgets/padding_builder.dart';
import 'package:rune/src/builders/widgets/paginated_data_table_builder.dart';
import 'package:rune/src/builders/widgets/popup_menu_button_builder.dart';
import 'package:rune/src/builders/widgets/popup_menu_divider_builder.dart';
import 'package:rune/src/builders/widgets/popup_menu_item_builder.dart';
import 'package:rune/src/builders/widgets/positioned_builder.dart';
import 'package:rune/src/builders/widgets/radio_builder.dart';
import 'package:rune/src/builders/widgets/radio_list_tile_builder.dart';
import 'package:rune/src/builders/widgets/reorderable_list_view_builder.dart';
import 'package:rune/src/builders/widgets/rotation_transition_builder.dart';
import 'package:rune/src/builders/widgets/row_builder.dart';
import 'package:rune/src/builders/widgets/rune_compose_builder.dart';
import 'package:rune/src/builders/widgets/safe_area_builder.dart';
import 'package:rune/src/builders/widgets/scaffold_builder.dart';
import 'package:rune/src/builders/widgets/scale_transition_builder.dart';
import 'package:rune/src/builders/widgets/search_bar_builder.dart';
import 'package:rune/src/builders/widgets/segmented_button_builder.dart';
import 'package:rune/src/builders/widgets/semantics_builder.dart';
import 'package:rune/src/builders/widgets/simple_dialog_builder.dart';
import 'package:rune/src/builders/widgets/simple_dialog_option_builder.dart';
import 'package:rune/src/builders/widgets/single_child_scroll_view_builder.dart';
import 'package:rune/src/builders/widgets/size_transition_builder.dart';
import 'package:rune/src/builders/widgets/sized_box_builder.dart';
import 'package:rune/src/builders/widgets/slide_transition_builder.dart';
import 'package:rune/src/builders/widgets/slider_builder.dart';
import 'package:rune/src/builders/widgets/sliver_app_bar_builder.dart';
import 'package:rune/src/builders/widgets/sliver_fill_remaining_builder.dart';
import 'package:rune/src/builders/widgets/sliver_list_builder.dart';
import 'package:rune/src/builders/widgets/sliver_padding_builder.dart';
import 'package:rune/src/builders/widgets/sliver_to_box_adapter_builder.dart';
import 'package:rune/src/builders/widgets/spacer_builder.dart';
import 'package:rune/src/builders/widgets/stack_builder.dart';
import 'package:rune/src/builders/widgets/stateful_builder_builder.dart';
import 'package:rune/src/builders/widgets/stepper_builder.dart';
import 'package:rune/src/builders/widgets/stream_builder_builder.dart';
import 'package:rune/src/builders/widgets/switch_builder.dart';
import 'package:rune/src/builders/widgets/switch_list_tile_builder.dart';
import 'package:rune/src/builders/widgets/tab_bar_builder.dart';
import 'package:rune/src/builders/widgets/tab_builder.dart';
import 'package:rune/src/builders/widgets/text_builder.dart';
import 'package:rune/src/builders/widgets/text_button_builder.dart';
import 'package:rune/src/builders/widgets/text_field_builder.dart';
import 'package:rune/src/builders/widgets/text_form_field_builder.dart';
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
      // Material 3 buttons + search (v1.4.0).
      ..registerBuilder(const FilledButtonBuilder())
      ..registerBuilder(const OutlinedButtonBuilder())
      ..registerBuilder(const SegmentedButtonBuilder())
      ..registerBuilder(const SearchBarBuilder())
      // C.2: form inputs
      ..registerBuilder(const TextFieldBuilder())
      ..registerBuilder(const SwitchBuilder())
      ..registerBuilder(const CheckboxBuilder())
      // Form + validation + focus (v1.5.0).
      ..registerBuilder(const FormBuilder())
      ..registerBuilder(const TextFormFieldBuilder())
      ..registerBuilder(const FocusBuilder())
      ..registerBuilder(const FocusScopeBuilder())
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
      // Gesture primitives (v1.7.0).
      ..registerBuilder(const DraggableBuilder())
      ..registerBuilder(const LongPressDraggableBuilder())
      ..registerBuilder(const DragTargetBuilder())
      ..registerBuilder(const DismissibleBuilder())
      ..registerBuilder(const InteractiveViewerBuilder())
      ..registerBuilder(const ReorderableListViewBuilder())
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
      ..registerBuilder(const ChoiceChipBuilder())
      ..registerBuilder(const FilterChipBuilder())
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
      ..registerBuilder(const FractionallySizedBoxBuilder())
      // Stateful source.
      ..registerBuilder(const StatefulBuilderBuilder())
      // Closure-based builder widgets (v1.2.0).
      ..registerBuilder(const FutureBuilderBuilder())
      ..registerBuilder(const StreamBuilderBuilder())
      ..registerBuilder(const LayoutBuilderBuilder())
      ..registerBuilder(const OrientationBuilderBuilder())
      // Dialogs, overlays, popup menus (v1.3.0).
      ..registerBuilder(const AlertDialogBuilder())
      ..registerBuilder(const SimpleDialogBuilder())
      ..registerBuilder(const SimpleDialogOptionBuilder())
      ..registerBuilder(const DialogBuilder())
      ..registerBuilder(const PopupMenuButtonBuilder())
      ..registerBuilder(const PopupMenuItemBuilder())
      ..registerBuilder(const PopupMenuDividerBuilder())
      // Components (Phase F).
      ..registerBuilder(const RuneComposeBuilder())
      // Data tables + expansion (v1.8.0).
      ..registerBuilder(const DataTableBuilder())
      ..registerBuilder(const ExpansionTileBuilder())
      ..registerBuilder(const ExpansionPanelListBuilder())
      ..registerBuilder(const StepperBuilder())
      // Explicit animations (v1.9.0).
      ..registerBuilder(const FadeTransitionBuilder())
      ..registerBuilder(const SlideTransitionBuilder())
      ..registerBuilder(const ScaleTransitionBuilder())
      ..registerBuilder(const RotationTransitionBuilder())
      ..registerBuilder(const SizeTransitionBuilder())
      ..registerBuilder(const AnimatedBuilderBuilder())
      // v1.12.0 deferred-item closeout.
      ..registerBuilder(const ListenableBuilderBuilder())
      ..registerBuilder(const CheckedPopupMenuItemBuilder())
      ..registerBuilder(const BottomSheetBuilder())
      ..registerBuilder(const PaginatedDataTableBuilder());
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
      // Grid views (static children).
      ..registerBuilder(const GridViewCountBuilder())
      ..registerBuilder(const GridViewExtentBuilder())
      // Lazy lists / grids with closure itemBuilder (v1.2.0).
      ..registerBuilder(const ListViewBuilderBuilder())
      ..registerBuilder(const GridViewCountBuilderBuilder())
      ..registerBuilder(const GridViewExtentBuilderBuilder())
      // Slivers (grid variants).
      ..registerBuilder(const SliverGridCountBuilder())
      ..registerBuilder(const SliverGridExtentBuilder())
      // Sliver lazy variants (v1.2.0).
      ..registerBuilder(const SliverListBuilderBuilder())
      ..registerBuilder(const SliverGridCountBuilderBuilder())
      ..registerBuilder(const SliverGridExtentBuilderBuilder())
      // Transforms.
      ..registerBuilder(const OffsetBuilder())
      ..registerBuilder(const TransformScaleBuilder())
      ..registerBuilder(const TransformRotateBuilder())
      ..registerBuilder(const TransformTranslateBuilder())
      ..registerBuilder(const TransformFlipBuilder())
      // Components (Phase F).
      ..registerBuilder(const RuneComponentBuilder())
      // Controllers (v1.1.0).
      ..registerBuilder(const TextEditingControllerBuilder())
      ..registerBuilder(const ScrollControllerBuilder())
      ..registerBuilder(const FocusNodeBuilder())
      ..registerBuilder(const PageControllerBuilder())
      // Modal-UI values (v1.3.0).
      ..registerBuilder(const SnackBarBuilder())
      // Navigation routes (v1.6.0).
      ..registerBuilder(const MaterialPageRouteBuilder())
      ..registerBuilder(const CupertinoPageRouteBuilder())
      ..registerBuilder(const RouteSettingsBuilder())
      // Theme + Material 3 values (v1.4.0).
      ..registerBuilder(const ColorSchemeFromSeedBuilder())
      ..registerBuilder(const ThemeDataBuilder())
      ..registerBuilder(const ButtonSegmentBuilder())
      ..registerBuilder(const DateTimeBuilder())
      ..registerBuilder(const TimeOfDayBuilder())
      ..registerBuilder(const SearchAnchorBarBuilder())
      // Gesture primitives (v1.7.0).
      ..registerBuilder(const ValueKeyBuilder())
      // Data tables + expansion (v1.8.0).
      ..registerBuilder(const DataColumnBuilder())
      ..registerBuilder(const DataRowBuilder())
      ..registerBuilder(const DataCellBuilder())
      ..registerBuilder(const ExpansionPanelBuilder())
      ..registerBuilder(const StepBuilder())
      // Explicit animations (v1.9.0).
      ..registerBuilder(const AnimationControllerBuilder())
      ..registerBuilder(const TweenBuilder())
      ..registerBuilder(const ColorTweenBuilder())
      ..registerBuilder(const CurvedAnimationBuilder())
      // v1.12.0 deferred-item closeout.
      ..registerBuilder(const PageRouteBuilderBuilder())
      ..registerBuilder(const SnackBarActionBuilder())
      ..registerBuilder(const RelativeRectFromLTRBBuilder())
      ..registerBuilder(const FilledButtonTonalBuilder())
      ..registerBuilder(const RuneDataTableSourceBuilder());
  }

  /// Seeds [registry] with Phase 2a constants (Colors, enums,
  /// EdgeInsets.zero, BoxShape, FlexFit) and the Phase 2c Icons subset.
  static void registerConstants(ConstantRegistry registry) {
    registerPhase2aConstants(registry);
    registerPhase2cIcons(registry);
  }
}
