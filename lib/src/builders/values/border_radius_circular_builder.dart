import 'package:flutter/painting.dart';
import 'package:rune/rune.dart' show ArgumentException;
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart' show ArgumentException;
import 'package:rune/src/core/rune_context.dart';

/// Builds `BorderRadius.circular(num)` from a single positional numeric
/// argument. All four corners receive the same radius.
final class BorderRadiusCircularBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const BorderRadiusCircularBuilder();

  @override
  String get typeName => 'BorderRadius';

  @override
  String? get constructorName => 'circular';

  /// Builds a [BorderRadius.circular] from the first positional argument,
  /// which must be a [num]. Throws [ArgumentException] when absent.
  @override
  BorderRadius build(ResolvedArguments args, RuneContext ctx) {
    final value =
        args.requirePositional<num>(0, source: 'BorderRadius.circular');
    return BorderRadius.circular(value.toDouble());
  }
}
