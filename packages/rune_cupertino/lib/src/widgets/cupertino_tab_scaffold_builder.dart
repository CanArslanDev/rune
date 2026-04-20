import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';
// ignore: implementation_imports
import 'package:rune/src/builders/closure_builder_helpers.dart'
    show toIndexedBuilder;

/// Builds [CupertinoTabScaffold], the iOS-style tabbed container that
/// pairs a [CupertinoTabBar] with per-tab content built lazily through
/// an `(BuildContext, int) -> Widget` closure.
///
/// Supported named arguments:
/// - `tabBar` ([CupertinoTabBar], required) - the bar rendered at the
///   bottom of the scaffold. Flutter insists the value be a
///   [CupertinoTabBar] instance specifically; passing a plain
///   [PreferredSizeWidget] is rejected at construction time by
///   Flutter, so any non-matching value triggers a type error that
///   [RuneView] surfaces through `onError`.
/// - `tabBuilder` (closure `(ctx, index) -> Widget`, required) -
///   evaluated on demand for each selected tab. Arity-2 is enforced
///   by the shared `toIndexedBuilder` helper; the closure body must
///   resolve to a [Widget] at invocation time.
/// - `backgroundColor` ([Color]?) - scaffold backdrop.
///
/// The `toIndexedBuilder` helper lives in the main `rune` package
/// under `lib/src/builders/closure_builder_helpers.dart`. It is
/// imported here via the `implementation_imports`-suppressed path
/// because the helper is not part of the main package's public
/// barrel; the suppression is intentional and narrowly scoped to
/// this one cross-bridge reuse.
final class CupertinoTabScaffoldBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoTabScaffoldBuilder();

  @override
  String get typeName => 'CupertinoTabScaffold';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final tabBar = args.require<CupertinoTabBar>(
      'tabBar',
      source: 'CupertinoTabScaffold',
    );
    final builder = toIndexedBuilder(
      args.named['tabBuilder'],
      'CupertinoTabScaffold',
    );
    return CupertinoTabScaffold(
      tabBar: tabBar,
      tabBuilder: builder,
      backgroundColor: args.get<Color>('backgroundColor'),
    );
  }
}
