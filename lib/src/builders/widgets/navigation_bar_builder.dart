import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material 3 [NavigationBar] — the preferred Material 3
/// alternative to [BottomNavigationBar]. Both coexist in the default
/// registry so consumers can pick their visual style.
///
/// Source arguments:
/// - `destinations` (`List<NavigationDestination>`) — required; must
///   contain at least two destinations (Flutter's own assertion).
///   Entries that are not [NavigationDestination] are silently filtered
///   out.
/// - `selectedIndex` (`int`) — required; the currently selected tab.
///   The host owns state: dispatch via `onDestinationSelected` and
///   rebuild with a new index.
/// - `onDestinationSelected` (`String?`) — optional event name;
///   dispatches `(eventName, [newIndex])` through [RuneContext.events]
///   when a destination is tapped. A missing event leaves Flutter's
///   slot `null`.
/// - `backgroundColor`, `indicatorColor` (`Color?`), `elevation`,
///   `height` (`num?`) — theming overrides.
final class NavigationBarBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const NavigationBarBuilder();

  @override
  String get typeName => 'NavigationBar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawDestinations = args.require<List<Object?>>(
      'destinations',
      source: 'NavigationBar',
    );
    final destinations = rawDestinations
        .whereType<Widget>()
        .toList(growable: false);
    if (destinations.length < 2) {
      throw ArgumentException(
        'NavigationBar',
        'NavigationBar requires at least 2 destinations, '
            'got ${destinations.length}',
      );
    }
    return NavigationBar(
      destinations: destinations,
      selectedIndex: args.require<int>(
        'selectedIndex',
        source: 'NavigationBar',
      ),
      onDestinationSelected: valueEventCallback<int>(
        args.named['onDestinationSelected'],
        ctx.events,
      ),
      backgroundColor: args.get<Color>('backgroundColor'),
      elevation: args.get<num>('elevation')?.toDouble(),
      height: args.get<num>('height')?.toDouble(),
      indicatorColor: args.get<Color>('indicatorColor'),
    );
  }
}
