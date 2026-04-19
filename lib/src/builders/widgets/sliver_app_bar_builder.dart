import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SliverAppBar] — a Material app bar that collapses as the
/// enclosing [CustomScrollView] scrolls.
///
/// Optional named args: `title`, `leading`, `actions` (List<Widget>),
/// `floating`, `pinned`, `snap`, `expandedHeight`, `backgroundColor`,
/// `elevation`, `centerTitle`, `flexibleSpace`. Non-Widget entries in
/// `actions` are filtered out.
final class SliverAppBarBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SliverAppBarBuilder();

  @override
  String get typeName => 'SliverAppBar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawActions = args.get<List<Object?>>('actions');
    final actions = rawActions?.whereType<Widget>().toList(growable: false);
    return SliverAppBar(
      title: args.get<Widget>('title'),
      leading: args.get<Widget>('leading'),
      actions: actions,
      floating: args.getOr<bool>('floating', false),
      pinned: args.getOr<bool>('pinned', false),
      snap: args.getOr<bool>('snap', false),
      expandedHeight: args.get<num>('expandedHeight')?.toDouble(),
      backgroundColor: args.get<Color>('backgroundColor'),
      elevation: args.get<num>('elevation')?.toDouble(),
      centerTitle: args.get<bool>('centerTitle'),
      flexibleSpace: args.get<Widget>('flexibleSpace'),
    );
  }
}
