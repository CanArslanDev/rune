import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [TabBar].
///
/// By default, a host-provided [DefaultTabController] ancestor drives
/// the selection state. When the optional `controller` arg is supplied,
/// that [TabController] is used directly (bypassing the default
/// controller). The controller itself is typically passed in through
/// `RuneView.data` since Rune does not yet construct [TabController]
/// at source level (it requires a [TickerProvider]).
///
/// Source arguments:
/// - `tabs` (`List<Widget>`): optional but effectively required in
///   practice. Entries that are not widgets are silently filtered.
///   Typically populated with [Tab] builders.
/// - `controller` ([TabController]): optional explicit controller.
///   When absent, the nearest ancestor [DefaultTabController] drives
///   selection.
/// - `onTap` (`String?`): optional event name; dispatches
///   `(eventName, [newIndex])` when a tab is tapped. Use for side
///   effects, not for driving selection state; the controller already
///   owns the visible selection.
/// - `indicatorColor`, `labelColor`, `unselectedLabelColor` (`Color?`):
///   theming overrides.
/// - `isScrollable` (`bool`): defaults to `false`.
final class TabBarBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const TabBarBuilder();

  @override
  String get typeName => 'TabBar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawTabs = args.get<List<Object?>>('tabs');
    final tabs = rawTabs == null
        ? const <Widget>[]
        : rawTabs.whereType<Widget>().toList(growable: false);
    return TabBar(
      tabs: tabs,
      controller: args.get<TabController>('controller'),
      onTap: valueEventCallback<int>(args.named['onTap'], ctx.events),
      indicatorColor: args.get<Color>('indicatorColor'),
      labelColor: args.get<Color>('labelColor'),
      unselectedLabelColor: args.get<Color>('unselectedLabelColor'),
      isScrollable: args.getOr<bool>('isScrollable', false),
    );
  }
}
