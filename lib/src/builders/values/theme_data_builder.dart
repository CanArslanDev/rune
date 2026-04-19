import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [ThemeData] covering the most commonly-templated slots.
///
/// Source arguments (all optional):
/// - `colorScheme` ([ColorScheme]?) - typically sourced from
///   `ColorScheme.fromSeed(...)`.
/// - `useMaterial3` ([bool]?). Defaults to `true` because v1.4.0 ships
///   Material 3 widgets as first-class; consumers targeting classic
///   Material 2 must pass `false` explicitly.
/// - `brightness` ([Brightness]?).
/// - `primaryColor` ([Color]?).
/// - `scaffoldBackgroundColor` ([Color]?).
/// - `cardColor` ([Color]?).
/// - `dividerColor` ([Color]?).
/// - `materialTapTargetSize` ([MaterialTapTargetSize]?).
///
/// `textTheme` and other compound slots are intentionally deferred to
/// later phases - v1.4.0 focuses on the seed-derived colour surface.
final class ThemeDataBuilder implements RuneValueBuilder {
  /// Const constructor - the builder is stateless.
  const ThemeDataBuilder();

  @override
  String get typeName => 'ThemeData';

  @override
  String? get constructorName => null;

  @override
  ThemeData build(ResolvedArguments args, RuneContext ctx) {
    return ThemeData(
      colorScheme: args.get<ColorScheme>('colorScheme'),
      useMaterial3: args.getOr<bool>('useMaterial3', true),
      brightness: args.get<Brightness>('brightness'),
      primaryColor: args.get<Color>('primaryColor'),
      scaffoldBackgroundColor: args.get<Color>('scaffoldBackgroundColor'),
      cardColor: args.get<Color>('cardColor'),
      dividerColor: args.get<Color>('dividerColor'),
      materialTapTargetSize:
          args.get<MaterialTapTargetSize>('materialTapTargetSize'),
    );
  }
}
