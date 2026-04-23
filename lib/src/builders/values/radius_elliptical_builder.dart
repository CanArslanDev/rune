import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart' show ArgumentException;
import 'package:rune/src/core/rune_context.dart';

/// Builds `Radius.elliptical(x, y)` from two positional nums. Raises
/// [ArgumentException] when either position is absent. Pair with
/// `BorderRadius.only(...)` or `.all(...)` to use elliptical corners.
final class RadiusEllipticalBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const RadiusEllipticalBuilder();

  @override
  String get typeName => 'Radius';

  @override
  String? get constructorName => 'elliptical';

  @override
  Radius build(ResolvedArguments args, RuneContext ctx) {
    final x = args.requirePositional<num>(0, source: 'Radius.elliptical');
    final y = args.requirePositional<num>(1, source: 'Radius.elliptical');
    return Radius.elliptical(x.toDouble(), y.toDouble());
  }
}
