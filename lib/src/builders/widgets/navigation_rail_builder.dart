import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material 3 [NavigationRail] — the landscape / tablet variant
/// of [NavigationBar], rendering a vertical rail at the side of the
/// viewport.
///
/// Source arguments:
/// - `destinations` (`List<NavigationRailDestination>`) — required;
///   must contain at least two destinations. Entries that are not
///   [NavigationRailDestination] are silently filtered out.
/// - `selectedIndex` (`int?`) — optional; the currently selected tab.
///   `null` renders the rail unselected.
/// - `onDestinationSelected` (`String?`) — optional event name;
///   dispatches `(eventName, [newIndex])` through [RuneContext.events]
///   when a destination is tapped.
/// - `extended` (`bool`) — expands the rail to show labels alongside
///   icons. Defaults to `false`.
/// - `labelType` ([NavigationRailLabelType]?) — `none`, `selected`,
///   or `all`. Mutually exclusive with `extended: true`.
/// - `backgroundColor` (`Color?`), `elevation`, `minWidth` (`num?`) —
///   theming / sizing overrides.
/// - `leading`, `trailing` (`Widget?`) — optional widgets above /
///   below the destinations list.
final class NavigationRailBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const NavigationRailBuilder();

  @override
  String get typeName => 'NavigationRail';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawDestinations = args.require<List<Object?>>(
      'destinations',
      source: 'NavigationRail',
    );
    final destinations = rawDestinations
        .whereType<NavigationRailDestination>()
        .toList(growable: false);
    if (destinations.length < 2) {
      throw ArgumentException(
        'NavigationRail',
        'NavigationRail requires at least 2 destinations, '
            'got ${destinations.length}',
      );
    }
    return NavigationRail(
      destinations: destinations,
      selectedIndex: args.get<int>('selectedIndex'),
      onDestinationSelected: valueEventCallback<int>(
        args.get<String>('onDestinationSelected'),
        ctx.events,
      ),
      extended: args.getOr<bool>('extended', false),
      labelType: args.get<NavigationRailLabelType>('labelType'),
      backgroundColor: args.get<Color>('backgroundColor'),
      elevation: args.get<num>('elevation')?.toDouble(),
      minWidth: args.get<num>('minWidth')?.toDouble(),
      leading: args.get<Widget>('leading'),
      trailing: args.get<Widget>('trailing'),
    );
  }
}
