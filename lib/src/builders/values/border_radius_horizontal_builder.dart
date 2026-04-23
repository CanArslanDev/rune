import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `BorderRadius.horizontal(left?, right?)`. Both named args are
/// optional [Radius] values and default to [Radius.zero] when absent.
/// Use when the left pair should match each other and the right pair
/// should match each other.
final class BorderRadiusHorizontalBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const BorderRadiusHorizontalBuilder();

  @override
  String get typeName => 'BorderRadius';

  @override
  String? get constructorName => 'horizontal';

  @override
  BorderRadius build(ResolvedArguments args, RuneContext ctx) {
    return BorderRadius.horizontal(
      left: args.get<Radius>('left') ?? Radius.zero,
      right: args.get<Radius>('right') ?? Radius.zero,
    );
  }
}
