import 'package:rune/src/builders/values/edge_insets_all_builder.dart';
import 'package:rune/src/builders/widgets/column_builder.dart';
import 'package:rune/src/builders/widgets/container_builder.dart';
import 'package:rune/src/builders/widgets/row_builder.dart';
import 'package:rune/src/builders/widgets/sized_box_builder.dart';
import 'package:rune/src/builders/widgets/text_builder.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

/// Top-level configuration handed to a [RuneView]. Bundles the widget and
/// value registries that the resolver consults during a render.
///
/// Immutable by convention in Phase 1: registries are expected to be
/// populated at construction and left alone afterward. Phase 2 may tighten
/// this with a `freeze()` step.
final class RuneConfig {
  /// Creates a configuration. Both registries default to empty if not
  /// supplied.
  RuneConfig({
    WidgetRegistry? widgets,
    ValueRegistry? values,
  })  : widgets = widgets ?? WidgetRegistry(),
        values = values ?? ValueRegistry();

  /// Creates a configuration with the Phase-1 widget and value builders
  /// pre-registered: `Text`, `SizedBox`, `Container`, `Column`, `Row`, and
  /// `EdgeInsets.all`.
  factory RuneConfig.defaults() {
    final config = RuneConfig();
    config.widgets
      ..registerBuilder(const TextBuilder())
      ..registerBuilder(const SizedBoxBuilder())
      ..registerBuilder(const ContainerBuilder())
      ..registerBuilder(const ColumnBuilder())
      ..registerBuilder(const RowBuilder());
    config.values.registerBuilder(const EdgeInsetsAllBuilder());
    return config;
  }

  /// Registry of widget builders consulted by `InvocationResolver`.
  final WidgetRegistry widgets;

  /// Registry of value builders consulted for non-widget constructor calls.
  final ValueRegistry values;
}
