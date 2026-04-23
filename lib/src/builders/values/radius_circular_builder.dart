import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart' show ArgumentException;
import 'package:rune/src/core/rune_context.dart';

/// Builds `Radius.circular(num)` from a single positional numeric
/// argument. Raises [ArgumentException] when absent. Pair with
/// `BorderRadius.only(...)` to compose non-uniform corner radii.
final class RadiusCircularBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const RadiusCircularBuilder();

  @override
  String get typeName => 'Radius';

  @override
  String? get constructorName => 'circular';

  @override
  Radius build(ResolvedArguments args, RuneContext ctx) {
    final value = args.requirePositional<num>(0, source: 'Radius.circular');
    return Radius.circular(value.toDouble());
  }
}
