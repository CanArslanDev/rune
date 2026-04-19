import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `SliverList.builder(...)`: a lazily constructed sliver list
/// whose cells come from an `itemBuilder` closure.
///
/// Registered as a [RuneValueBuilder] because `SliverList.builder` is a
/// named constructor. The builder still returns a sliver-shaped widget
/// (mount inside `CustomScrollView.slivers`).
///
/// Required: `itemCount: int`, `itemBuilder: (ctx, i) => Widget`.
final class SliverListBuilderBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const SliverListBuilderBuilder();

  @override
  String get typeName => 'SliverList';

  @override
  String? get constructorName => 'builder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final itemCount = args.require<int>(
      'itemCount',
      source: 'SliverList.builder',
    );
    final itemBuilder = toIndexedBuilder(
      args.named['itemBuilder'],
      'SliverList.builder',
    );
    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
