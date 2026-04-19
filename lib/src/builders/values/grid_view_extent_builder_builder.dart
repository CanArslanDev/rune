import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `GridView.extentBuilder(...)`: a Rune-sugar named constructor
/// that combines `SliverGridDelegateWithMaxCrossAxisExtent` with
/// `GridView.builder`'s lazy itemBuilder.
///
/// Required: `maxCrossAxisExtent: num`,
/// `itemBuilder: (ctx, i) => Widget`.
/// Optional: `itemCount: int?` (unbounded when null),
/// `mainAxisSpacing`, `crossAxisSpacing`, `childAspectRatio`,
/// `scrollDirection`, `padding`, `shrinkWrap`, `reverse`, `controller`.
final class GridViewExtentBuilderBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const GridViewExtentBuilderBuilder();

  @override
  String get typeName => 'GridView';

  @override
  String? get constructorName => 'extentBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final maxExtent = args
        .require<num>(
          'maxCrossAxisExtent',
          source: 'GridView.extentBuilder',
        )
        .toDouble();
    final itemBuilder = toIndexedBuilder(
      args.named['itemBuilder'],
      'GridView.extentBuilder',
    );
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxExtent,
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
