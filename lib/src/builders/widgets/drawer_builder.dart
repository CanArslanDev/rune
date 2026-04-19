import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Drawer] — the sliding side-menu panel typically supplied
/// to `Scaffold.drawer` / `Scaffold.endDrawer`.
///
/// Supported named args: `child`, `backgroundColor`, `elevation`
/// ([num] coerced to double), `width` ([num] coerced to double).
/// `shape` ([ShapeBorder]) is deferred — not in Rune's value-builder
/// surface.
final class DrawerBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const DrawerBuilder();

  @override
  String get typeName => 'Drawer';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Drawer(
      backgroundColor: args.get<Color>('backgroundColor'),
      elevation: args.get<num>('elevation')?.toDouble(),
      width: args.get<num>('width')?.toDouble(),
      child: args.get<Widget>('child'),
    );
  }
}
