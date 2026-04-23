import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Border.all(color, width, style, strokeAlign)` using
/// Flutter's own defaults (`Colors.black`, `1.0`, `BorderStyle.solid`,
/// `strokeAlignInside`).
///
/// All four named args are optional. `width` accepts any [num] and is
/// coerced to double so source can write `Border.all(width: 2)` without
/// a trailing `.0`. `strokeAlign` matches Flutter's 3.7+ surface and is
/// optional.
final class BorderAllBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const BorderAllBuilder();

  @override
  String get typeName => 'Border';

  @override
  String? get constructorName => 'all';

  @override
  Border build(ResolvedArguments args, RuneContext ctx) {
    return Border.all(
      color: args.get<Color>('color') ?? const Color(0xFF000000),
      width: args.get<num>('width')?.toDouble() ?? 1.0,
      style: args.get<BorderStyle>('style') ?? BorderStyle.solid,
      strokeAlign: args.get<num>('strokeAlign')?.toDouble() ??
          BorderSide.strokeAlignInside,
    );
  }
}
