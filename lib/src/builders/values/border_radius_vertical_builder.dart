import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `BorderRadius.vertical(top?, bottom?)`. Both named args are
/// optional [Radius] values and default to [Radius.zero] when absent.
/// Use when the top pair should match each other and the bottom pair
/// should match each other.
final class BorderRadiusVerticalBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const BorderRadiusVerticalBuilder();

  @override
  String get typeName => 'BorderRadius';

  @override
  String? get constructorName => 'vertical';

  @override
  BorderRadius build(ResolvedArguments args, RuneContext ctx) {
    return BorderRadius.vertical(
      top: args.get<Radius>('top') ?? Radius.zero,
      bottom: args.get<Radius>('bottom') ?? Radius.zero,
    );
  }
}
