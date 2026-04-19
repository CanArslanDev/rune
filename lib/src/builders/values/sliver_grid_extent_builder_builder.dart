import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `SliverGrid.extentBuilder(...)`: a Rune-sugar named constructor
/// that combines `SliverGridDelegateWithMaxCrossAxisExtent` with a lazy
/// `SliverChildBuilderDelegate` fed by the supplied
/// `itemBuilder` `RuneClosure`.
///
/// Mount inside `CustomScrollView.slivers`.
///
/// Required: `maxCrossAxisExtent: num`,
/// `itemBuilder: (ctx, i) => Widget`.
/// Optional: `itemCount: int?` (unbounded when null),
/// `mainAxisSpacing`, `crossAxisSpacing`, `childAspectRatio`.
final class SliverGridExtentBuilderBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const SliverGridExtentBuilderBuilder();

  @override
  String get typeName => 'SliverGrid';

  @override
  String? get constructorName => 'extentBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final maxExtent = args
        .require<num>(
          'maxCrossAxisExtent',
          source: 'SliverGrid.extentBuilder',
        )
        .toDouble();
    final itemBuilder = toIndexedBuilder(
      args.named['itemBuilder'],
      'SliverGrid.extentBuilder',
    );
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxExtent,
        mainAxisSpacing:
            args.get<num>('mainAxisSpacing')?.toDouble() ?? 0.0,
        crossAxisSpacing:
            args.get<num>('crossAxisSpacing')?.toDouble() ?? 0.0,
        childAspectRatio:
            args.get<num>('childAspectRatio')?.toDouble() ?? 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: args.get<int>('itemCount'),
      ),
    );
  }
}
