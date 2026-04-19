import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `SliverGrid.count(...)` — a sliver grid with a fixed number of
/// cells along the cross axis.
///
/// Registered as a [RuneValueBuilder] because `SliverGrid.count` is a
/// named constructor; Rune dispatches `TypeName.ctor(...)` invocations
/// through the value registry when no plain `TypeName` widget builder
/// matches. The builder still returns a [Widget].
///
/// Required: `crossAxisCount: int`. Optional: `children`,
/// `mainAxisSpacing`, `crossAxisSpacing`, `childAspectRatio`. Non-Widget
/// entries in `children` are dropped silently.
final class SliverGridCountBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const SliverGridCountBuilder();

  @override
  String get typeName => 'SliverGrid';

  @override
  String? get constructorName => 'count';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final crossAxisCount = args.require<int>(
      'crossAxisCount',
      source: 'SliverGrid.count',
    );
    final children = (args.get<List<Object?>>('children') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    return SliverGrid.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: args.get<num>('mainAxisSpacing')?.toDouble() ?? 0.0,
      crossAxisSpacing: args.get<num>('crossAxisSpacing')?.toDouble() ?? 0.0,
      childAspectRatio: args.get<num>('childAspectRatio')?.toDouble() ?? 1.0,
      children: children,
    );
  }
}
