import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `GridView.countBuilder(...)`: a Rune-sugar named constructor
/// that combines `SliverGridDelegateWithFixedCrossAxisCount` with
/// `GridView.builder`'s lazy itemBuilder path. Materialised grid cells
/// come from the `RuneClosure` on demand.
///
/// The underlying Flutter API expects a `gridDelegate:` +
/// `itemBuilder:` pair; Rune exposes a flatter shape so source authors
/// do not have to construct a delegate by hand. The sugar mapping is
/// fixed: `crossAxisCount` → `SliverGridDelegateWithFixedCrossAxisCount`
/// with the supplied `mainAxisSpacing`, `crossAxisSpacing`, and
/// `childAspectRatio`. Use `GridViewExtentBuilderBuilder` for the
/// extent-based cousin.
///
/// Required: `crossAxisCount: int`, `itemBuilder: (ctx, i) => Widget`.
/// Optional: `itemCount: int?` (unbounded when null),
/// `mainAxisSpacing`, `crossAxisSpacing`, `childAspectRatio`,
/// `scrollDirection`, `padding`, `shrinkWrap`, `reverse`, `controller`.
final class GridViewCountBuilderBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const GridViewCountBuilderBuilder();

  @override
  String get typeName => 'GridView';

  @override
  String? get constructorName => 'countBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final crossAxisCount = args.require<int>(
      'crossAxisCount',
      source: 'GridView.countBuilder',
    );
    final itemBuilder = toIndexedBuilder(
      args.named['itemBuilder'],
      'GridView.countBuilder',
    );
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing:
            args.get<num>('mainAxisSpacing')?.toDouble() ?? 0.0,
        crossAxisSpacing:
            args.get<num>('crossAxisSpacing')?.toDouble() ?? 0.0,
        childAspectRatio:
            args.get<num>('childAspectRatio')?.toDouble() ?? 1.0,
      ),
      itemCount: args.get<int>('itemCount'),
      itemBuilder: itemBuilder,
      scrollDirection: args.getOr<Axis>('scrollDirection', Axis.vertical),
      reverse: args.getOr<bool>('reverse', false),
      shrinkWrap: args.getOr<bool>('shrinkWrap', false),
      padding: args.get<EdgeInsetsGeometry>('padding'),
      controller: args.get<ScrollController>('controller'),
    );
  }
}
