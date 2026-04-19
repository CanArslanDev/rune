import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [BottomNavigationBar].
///
/// Source arguments:
/// - `items` (`List<BottomNavigationBarItem>`) — required; must contain
///   at least two items (Flutter's own assertion). Entries that are not
///   `BottomNavigationBarItem` are silently filtered out.
/// - `currentIndex` (`int`) — required; the currently selected tab. The
///   host owns state: dispatch via `onTap` and rebuild with a new index.
/// - `onTap` (`String?`) — optional event name; dispatches
///   `(eventName, [newIndex])` through [RuneContext.events] when a tab
///   is tapped. A missing `onTap` leaves Flutter's slot `null`.
/// - `type` ([BottomNavigationBarType]?) — `fixed` (default for 3 or
///   fewer items) or `shifting` (animated reveal).
/// - `selectedItemColor`, `unselectedItemColor`, `backgroundColor`
///   (`Color?`) — theming overrides.
///
/// The host owns selection state — same contract as Slider/Switch/
/// Checkbox: interactions fire named events carrying the new value; the
/// host updates its data map and re-renders.
final class BottomNavigationBarBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const BottomNavigationBarBuilder();

  @override
  String get typeName => 'BottomNavigationBar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawItems = args.require<List<Object?>>(
      'items',
      source: 'BottomNavigationBar',
    );
    final items = rawItems
        .whereType<BottomNavigationBarItem>()
        .toList(growable: false);
    if (items.length < 2) {
      throw ArgumentException(
        'BottomNavigationBar',
        'BottomNavigationBar requires at least 2 BottomNavigationBarItems, '
            'got ${items.length}',
      );
    }
    return BottomNavigationBar(
      items: items,
      currentIndex: args.require<int>(
        'currentIndex',
        source: 'BottomNavigationBar',
      ),
      onTap: valueEventCallback<int>(args.named['onTap'], ctx.events),
      type: args.get<BottomNavigationBarType>('type'),
      selectedItemColor: args.get<Color>('selectedItemColor'),
      unselectedItemColor: args.get<Color>('unselectedItemColor'),
      backgroundColor: args.get<Color>('backgroundColor'),
    );
  }
}
