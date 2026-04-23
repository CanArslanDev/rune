import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart' show ArgumentException;
import 'package:rune/src/core/rune_context.dart';

/// Builds `Color.fromRGBO(red, green, blue, opacity)` from three
/// positional ints plus a positional [num] opacity in the inclusive
/// 0.0–1.0 range. Ints are coerced to double for opacity so source can
/// write `Color.fromRGBO(255, 0, 0, 1)` without a trailing `.0`.
///
/// Raises [ArgumentException] when any of the four positions is absent.
final class ColorFromRgboBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const ColorFromRgboBuilder();

  @override
  String get typeName => 'Color';

  @override
  String? get constructorName => 'fromRGBO';

  @override
  Color build(ResolvedArguments args, RuneContext ctx) {
    final r = args.requirePositional<int>(0, source: 'Color.fromRGBO');
    final g = args.requirePositional<int>(1, source: 'Color.fromRGBO');
    final b = args.requirePositional<int>(2, source: 'Color.fromRGBO');
    final o = args.requirePositional<num>(3, source: 'Color.fromRGBO');
    return Color.fromRGBO(r, g, b, o.toDouble());
  }
}
