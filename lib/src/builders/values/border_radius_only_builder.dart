import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `BorderRadius.only(topLeft?, topRight?, bottomLeft?,
/// bottomRight?)` from any subset of the four named [Radius] args.
/// Omitted corners default to [Radius.zero]. No positional args are
/// accepted; with zero named args this returns [BorderRadius.zero].
final class BorderRadiusOnlyBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const BorderRadiusOnlyBuilder();

  @override
  String get typeName => 'BorderRadius';

  @override
  String? get constructorName => 'only';

  @override
  BorderRadius build(ResolvedArguments args, RuneContext ctx) {
    return BorderRadius.only(
      topLeft: args.get<Radius>('topLeft') ?? Radius.zero,
      topRight: args.get<Radius>('topRight') ?? Radius.zero,
      bottomLeft: args.get<Radius>('bottomLeft') ?? Radius.zero,
      bottomRight: args.get<Radius>('bottomRight') ?? Radius.zero,
    );
  }
}
