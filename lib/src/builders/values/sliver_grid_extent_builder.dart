import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `SliverGrid.extent(...)` — a sliver grid whose cell count is
/// derived from a maximum cross-axis extent.
///
/// Registered as a [RuneValueBuilder] because `SliverGrid.extent` is a
/// named constructor. The builder still returns a [Widget].
///
/// Required: `maxCrossAxisExtent: num`. Optional: `children`,
/// `mainAxisSpacing`, `crossAxisSpacing`, `childAspectRatio`. Non-Widget
/// entries in `children` are dropped silently.
final class SliverGridExtentBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const SliverGridExtentBuilder();

  @override
  String get typeName => 'SliverGrid';

  @override
  String? get constructorName => 'extent';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final maxCrossAxisExtent = args.require<num>(
      'maxCrossAxisExtent',
      source: 'SliverGrid.extent',
    ).toDouble();
    final children = (args.get<List<Object?>>('children') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    return SliverGrid.extent(
      maxCrossAxisExtent: maxCrossAxisExtent,
      mainAxisSpacing: args.get<num>('mainAxisSpacing')?.toDouble() ?? 0.0,
      crossAxisSpacing: args.get<num>('crossAxisSpacing')?.toDouble() ?? 0.0,
      childAspectRatio: args.get<num>('childAspectRatio')?.toDouble() ?? 1.0,
      children: children,
    );
  }
}
