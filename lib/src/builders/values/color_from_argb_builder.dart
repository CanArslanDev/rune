import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart' show ArgumentException;
import 'package:rune/src/core/rune_context.dart';

/// Builds `Color.fromARGB(alpha, red, green, blue)` from four positional
/// ints in the inclusive 0–255 range. Raises [ArgumentException] when any
/// of the four positions is absent.
final class ColorFromArgbBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const ColorFromArgbBuilder();

  @override
  String get typeName => 'Color';

  @override
  String? get constructorName => 'fromARGB';

  @override
  Color build(ResolvedArguments args, RuneContext ctx) {
    final a = args.requirePositional<int>(0, source: 'Color.fromARGB');
    final r = args.requirePositional<int>(1, source: 'Color.fromARGB');
    final g = args.requirePositional<int>(2, source: 'Color.fromARGB');
    final b = args.requirePositional<int>(3, source: 'Color.fromARGB');
    return Color.fromARGB(a, r, g, b);
  }
}
