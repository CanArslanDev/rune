import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Card] from optional `child`, `elevation`, `color`, and `margin`.
/// `shape` / `shadowColor` / `surfaceTintColor` are out of scope for
/// Phase 2c.
final class CardBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const CardBuilder();

  @override
  String get typeName => 'Card';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Card(
      elevation: args.get<num>('elevation')?.toDouble(),
      color: args.get<Color>('color'),
      margin: args.get<EdgeInsetsGeometry>('margin'),
      child: args.get<Widget>('child'),
    );
  }
}
