import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `BoxDecoration(color:, borderRadius:, shape:)` from optional
/// named arguments. Phase 2b scope — `border`, `boxShadow`, `gradient`,
/// `image`, and `backgroundBlendMode` will be added if a downstream
/// builder needs them.
final class BoxDecorationBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const BoxDecorationBuilder();

  @override
  String get typeName => 'BoxDecoration';

  @override
  String? get constructorName => null;

  /// Builds a [BoxDecoration] from optional named arguments: `color`,
  /// `borderRadius`, and `shape`. The `shape` defaults to
  /// [BoxShape.rectangle] when absent, matching Flutter's own default.
  @override
  BoxDecoration build(ResolvedArguments args, RuneContext ctx) {
    return BoxDecoration(
      color: args.get<Color>('color'),
      borderRadius: args.get<BorderRadiusGeometry>('borderRadius'),
      shape: args.getOr<BoxShape>('shape', BoxShape.rectangle),
    );
  }
}
