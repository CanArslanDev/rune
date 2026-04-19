import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [TabBar].
///
/// Assumes a host-provided [DefaultTabController] ancestor drives the
/// selection state — Rune source is not expected to construct the
/// controller (imperative state handling is out of scope). Same
/// contract as mounting an `AppBar` under a `Scaffold`: the widget
/// needs a specific ancestor to be usable.
///
/// Source arguments:
/// - `tabs` (`List<Widget>`) — optional but effectively required in
///   practice. Entries that are not widgets are silently filtered.
///   Typically populated with [Tab] builders.
/// - `onTap` (`String?`) — optional event name; dispatches
///   `(eventName, [newIndex])` when a tab is tapped. Use for side
///   effects, not for driving selection state — the controller already
///   owns the visible selection.
/// - `indicatorColor`, `labelColor`, `unselectedLabelColor` (`Color?`)
///   — theming overrides.
/// - `isScrollable` (`bool`) — defaults to `false`.
final class TabBarBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
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
      onTap: valueEventCallback<int>(args.get<String>('onTap'), ctx.events),
      indicatorColor: args.get<Color>('indicatorColor'),
      labelColor: args.get<Color>('labelColor'),
      unselectedLabelColor: args.get<Color>('unselectedLabelColor'),
      isScrollable: args.getOr<bool>('isScrollable', false),
    );
  }
}
