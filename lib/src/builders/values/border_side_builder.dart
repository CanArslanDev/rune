import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `BorderSide(color, width, style, strokeAlign)` using Flutter's
/// own defaults (`Colors.black`, `1.0`, `BorderStyle.solid`,
/// `strokeAlignInside`). Pair with `Border.symmetric(...)` or use
/// directly inside an `OutlineInputBorder` / `UnderlineInputBorder`.
final class BorderSideBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const BorderSideBuilder();

  @override
  String get typeName => 'BorderSide';

  @override
  String? get constructorName => null;

  @override
  BorderSide build(ResolvedArguments args, RuneContext ctx) {
    return BorderSide(
      color: args.get<Color>('color') ?? const Color(0xFF000000),
      width: args.get<num>('width')?.toDouble() ?? 1.0,
      style: args.get<BorderStyle>('style') ?? BorderStyle.solid,
      strokeAlign: args.get<num>('strokeAlign')?.toDouble() ??
          BorderSide.strokeAlignInside,
    );
  }
}
