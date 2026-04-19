import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `GridView.extent(...)` — a scrollable grid where each cell is
/// at most `maxCrossAxisExtent` along the cross axis; the grid picks the
/// number of cells per row to fit the available space.
///
/// Registered as a [RuneValueBuilder] because `GridView.extent` is a
/// named constructor; Rune dispatches `TypeName.ctor(...)` invocations
/// through the value registry when no plain `TypeName` widget builder
/// matches. The builder still returns a [Widget].
///
/// Required: `maxCrossAxisExtent: num`. Optional: `children`,
/// `mainAxisSpacing`, `crossAxisSpacing`, `childAspectRatio`,
/// `scrollDirection` (Axis), `padding`, `shrinkWrap`, `reverse`.
/// Non-Widget entries in `children` are dropped silently (matches the
/// Column / Row / Stack children-filter convention).
final class GridViewExtentBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const GridViewExtentBuilder();

  @override
  String get typeName => 'GridView';

  @override
  String? get constructorName => 'extent';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final maxExtent = args
        .require<num>('maxCrossAxisExtent', source: 'GridView.extent')
        .toDouble();
    final children = (args.get<List<Object?>>('children') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    return GridView.extent(
      maxCrossAxisExtent: maxExtent,
      mainAxisSpacing: args.get<num>('mainAxisSpacing')?.toDouble() ?? 0.0,
      crossAxisSpacing: args.get<num>('crossAxisSpacing')?.toDouble() ?? 0.0,
      childAspectRatio: args.get<num>('childAspectRatio')?.toDouble() ?? 1.0,
      scrollDirection: args.getOr<Axis>('scrollDirection', Axis.vertical),
      padding: args.get<EdgeInsetsGeometry>('padding'),
      shrinkWrap: args.getOr<bool>('shrinkWrap', false),
      reverse: args.getOr<bool>('reverse', false),
      children: children,
    );
  }
}
