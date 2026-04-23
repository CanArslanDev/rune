import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `BoxDecoration(color:, borderRadius:, shape:, border:, gradient:)`
/// from optional named arguments. `image` and `backgroundBlendMode` remain
/// out of scope and will land when a downstream builder needs them.
final class BoxDecorationBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const BoxDecorationBuilder();

  @override
  String get typeName => 'BoxDecoration';

  @override
  String? get constructorName => null;

  @override
  BoxDecoration build(ResolvedArguments args, RuneContext ctx) {
    return BoxDecoration(
      color: args.get<Color>('color'),
      borderRadius: args.get<BorderRadiusGeometry>('borderRadius'),
      shape: args.getOr<BoxShape>('shape', BoxShape.rectangle),
      border: args.get<BoxBorder>('border'),
      gradient: args.get<Gradient>('gradient'),
    );
  }
}
