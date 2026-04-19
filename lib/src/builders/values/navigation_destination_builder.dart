import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [NavigationDestination] — the Material 3 data class for one
/// tab in a [NavigationBar]. Required `icon` (Widget) and `label`
/// (String); optional `selectedIcon` (shown when the destination is
/// selected) and `tooltip`.
final class NavigationDestinationBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const NavigationDestinationBuilder();

  @override
  String get typeName => 'NavigationDestination';

  @override
  String? get constructorName => null;

  @override
  NavigationDestination build(ResolvedArguments args, RuneContext ctx) {
    return NavigationDestination(
      icon: args.require<Widget>('icon', source: 'NavigationDestination'),
      label: args.require<String>('label', source: 'NavigationDestination'),
      selectedIcon: args.get<Widget>('selectedIcon'),
      tooltip: args.get<String>('tooltip'),
    );
  }
}
