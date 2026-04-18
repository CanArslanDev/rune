import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart' show ArgumentException;
import 'package:rune/src/core/rune_context.dart';

/// Builds `Color(int)` from a single positional integer — typically a hex
/// literal like `0xFFFF0000`. Default-constructor builder; the named
/// constructors `Color.fromARGB` and `Color.fromRGBO` are out of scope
/// for Phase 2b and will land in a later phase if demand appears.
final class ColorBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const ColorBuilder();

  @override
  String get typeName => 'Color';

  @override
  String? get constructorName => null;

  /// Builds a [Color] from the first positional argument, which must be an
  /// [int] ARGB hex value. Throws [ArgumentException] when absent.
  @override
  Color build(ResolvedArguments args, RuneContext ctx) {
    final value = args.requirePositional<int>(0, source: 'Color');
    return Color(value);
  }
}
