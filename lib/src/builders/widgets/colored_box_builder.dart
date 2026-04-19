import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ColoredBox] — the efficient leaf that fills its child with a
/// solid [Color]. Required `color`; optional `child`.
final class ColoredBoxBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ColoredBoxBuilder();

  @override
  String get typeName => 'ColoredBox';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return ColoredBox(
      color: args.require<Color>('color', source: 'ColoredBox'),
      child: args.get<Widget>('child'),
    );
  }
}
