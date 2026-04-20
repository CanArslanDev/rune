import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoTabBar], the iOS-style tab strip at the bottom of
/// a [CupertinoTabScaffold].
///
/// The enclosing `BottomNavigationBarItem` value builder is provided
/// by the main `rune` defaults, so source strings can compose it
/// directly without additional bridge setup.
///
/// Supported named arguments:
/// - `items` (`List<BottomNavigationBarItem>`, required) - the tab
///   entries. Non-[BottomNavigationBarItem] values are silently
///   dropped, matching the Column/Row children-filter convention.
///   Flutter asserts at construction that the list has at least two
///   entries; malformed source surfaces through `RuneView.onError`.
/// - `currentIndex` (`int`) - zero-based index of the active tab.
///   Defaults to `0`.
/// - `onTap` (`String?` or closure) - dispatched with the tapped
///   index on tab selection. Omitted callback leaves the tab bar as
///   display-only.
/// - `backgroundColor` ([Color]?) - bar backdrop.
/// - `activeColor` ([Color]?) - tint for the currently selected tab.
/// - `inactiveColor` ([Color]?) - tint for unselected tabs.
/// - `iconSize` (`num?`) - per-icon display size; coerced to `double`.
final class CupertinoTabBarBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoTabBarBuilder();

  @override
  String get typeName => 'CupertinoTabBar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawItems = args.require<List<Object?>>(
      'items',
      source: 'CupertinoTabBar',
    );
    final items =
        rawItems.whereType<BottomNavigationBarItem>().toList(growable: false);
    return CupertinoTabBar(
      items: items,
      currentIndex: args.getOr<int>('currentIndex', 0),
      onTap: valueEventCallback<int>(args.named['onTap'], ctx.events),
      backgroundColor: args.get<Color>('backgroundColor'),
      activeColor: args.get<Color>('activeColor'),
      inactiveColor: args.get<Color>('inactiveColor') ??
          CupertinoColors.inactiveGray,
      iconSize: args.get<num>('iconSize')?.toDouble() ?? 30.0,
    );
  }
}
