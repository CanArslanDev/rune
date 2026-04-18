import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `TextStyle(...)` from optional named arguments. Phase 2b
/// covers: `fontSize`, `color`, `fontWeight`, `fontFamily`,
/// `letterSpacing`, `wordSpacing`, `height`, `fontStyle`. Other
/// `TextStyle` parameters (decoration, shadows, foreground, …) will
/// land when a Phase 2c/2d builder surfaces a live need.
final class TextStyleBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const TextStyleBuilder();

  @override
  String get typeName => 'TextStyle';

  @override
  String? get constructorName => null;

  /// Builds a [TextStyle] from optional named arguments: `fontSize`,
  /// `color`, `fontWeight`, `fontFamily`, `letterSpacing`, `wordSpacing`,
  /// `height`, and `fontStyle`. All parameters are optional; absent ones
  /// remain unset on the resulting [TextStyle].
  @override
  TextStyle build(ResolvedArguments args, RuneContext ctx) {
    return TextStyle(
      fontSize: args.get<num>('fontSize')?.toDouble(),
      color: args.get<Color>('color'),
      fontWeight: args.get<FontWeight>('fontWeight'),
      fontFamily: args.get<String>('fontFamily'),
      letterSpacing: args.get<num>('letterSpacing')?.toDouble(),
      wordSpacing: args.get<num>('wordSpacing')?.toDouble(),
      height: args.get<num>('height')?.toDouble(),
      fontStyle: args.get<FontStyle>('fontStyle'),
    );
  }
}
