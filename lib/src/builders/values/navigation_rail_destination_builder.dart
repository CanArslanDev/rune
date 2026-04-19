import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [NavigationRailDestination] — the data class for one tab in
/// a [NavigationRail]. Required `icon` and `label` (both Widgets, with
/// `label` typically a `Text`); optional `selectedIcon` and `padding`.
final class NavigationRailDestinationBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const NavigationRailDestinationBuilder();

  @override
  String get typeName => 'NavigationRailDestination';

  @override
  String? get constructorName => null;

  @override
  NavigationRailDestination build(ResolvedArguments args, RuneContext ctx) {
    return NavigationRailDestination(
      icon: args.require<Widget>('icon', source: 'NavigationRailDestination'),
      label: args.require<Widget>(
        'label',
        source: 'NavigationRailDestination',
      ),
      selectedIcon: args.get<Widget>('selectedIcon'),
      padding: args.get<EdgeInsetsGeometry>('padding'),
    );
  }
}
