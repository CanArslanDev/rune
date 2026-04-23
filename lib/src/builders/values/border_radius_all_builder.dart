import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `BorderRadius.all(Radius)` from a single positional [Radius].
///
/// Prefer `BorderRadius.circular(num)` when all four corners share the
/// same circular radius built from a number literal; this constructor
/// is the right shape when source already has a [Radius] value in hand
/// (e.g. passed in via `data:` or produced by `Radius.elliptical`).
final class BorderRadiusAllBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const BorderRadiusAllBuilder();

  @override
  String get typeName => 'BorderRadius';

  @override
  String? get constructorName => 'all';

  @override
  BorderRadius build(ResolvedArguments args, RuneContext ctx) {
    final radius =
        args.requirePositional<Radius>(0, source: 'BorderRadius.all');
    return BorderRadius.all(radius);
  }
}
