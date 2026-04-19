import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `SliverGrid.countBuilder(...)`: a Rune-sugar named constructor
/// that combines `SliverGridDelegateWithFixedCrossAxisCount` with a lazy
/// `SliverChildBuilderDelegate` fed by the supplied
/// `itemBuilder` `RuneClosure`.
///
/// Mount inside `CustomScrollView.slivers`.
///
/// Required: `crossAxisCount: int`, `itemBuilder: (ctx, i) => Widget`.
/// Optional: `itemCount: int?` (unbounded when null),
/// `mainAxisSpacing`, `crossAxisSpacing`, `childAspectRatio`.
final class SliverGridCountBuilderBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const SliverGridCountBuilderBuilder();

  @override
  String get typeName => 'SliverGrid';

  @override
  String? get constructorName => 'countBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final crossAxisCount = args.require<int>(
      'crossAxisCount',
      source: 'SliverGrid.countBuilder',
    );
    final itemBuilder = toIndexedBuilder(
      args.named['itemBuilder'],
      'SliverGrid.countBuilder',
    );
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
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
