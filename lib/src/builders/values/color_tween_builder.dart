import 'package:flutter/animation.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [ColorTween]. Both `begin` and `end` are optional and default
/// to `null`, matching Flutter's own [ColorTween] default constructor.
/// A null bound interpolates as a transparent instance of the non-null
/// bound, so `ColorTween(begin: null, end: Colors.blue)` fades a widget
/// in from transparent to blue.
final class ColorTweenBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const ColorTweenBuilder();

  @override
  String get typeName => 'ColorTween';

  @override
  String? get constructorName => null;

  @override
  ColorTween build(ResolvedArguments args, RuneContext ctx) {
    return ColorTween(
      begin: args.get<Color>('begin'),
      end: args.get<Color>('end'),
    );
  }
}
