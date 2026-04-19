import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [CustomScrollView] from a required `slivers: List<Widget>` plus
/// optional `scrollDirection`, `reverse`, `shrinkWrap`, and `primary`.
///
/// `CustomScrollView` is the entry point for composing scroll fragments
/// (slivers) that plain `ListView` / `GridView` cannot express — sticky
/// headers, collapsing app bars, mixed lists and grids. Non-Widget
/// entries in `slivers` are dropped silently, matching the children
/// filter convention used by `Column`, `Row`, `ListView`, etc. Each
/// retained entry must implement the sliver protocol
/// (`SliverList`, `SliverToBoxAdapter`, `SliverAppBar`, ...).
///
/// `.builder`-style lazy construction is not represented here — Rune's
/// source grammar does not yet support function literals.
final class CustomScrollViewBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const CustomScrollViewBuilder();

  @override
  String get typeName => 'CustomScrollView';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawSlivers = args.require<List<Object?>>(
      'slivers',
      source: 'CustomScrollView',
    );
    final slivers = rawSlivers.whereType<Widget>().toList(growable: false);
    return CustomScrollView(
      scrollDirection: args.getOr<Axis>('scrollDirection', Axis.vertical),
      reverse: args.getOr<bool>('reverse', false),
      shrinkWrap: args.getOr<bool>('shrinkWrap', false),
      primary: args.get<bool>('primary'),
      slivers: slivers,
    );
  }
}
