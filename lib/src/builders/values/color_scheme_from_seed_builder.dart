import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a Material 3 [ColorScheme] via the `ColorScheme.fromSeed(...)`
/// named constructor.
///
/// Source arguments:
/// - `seedColor` ([Color], required). The single hue that drives the
///   entire generated scheme.
/// - `brightness` ([Brightness]?). Defaults to [Brightness.light].
///
/// The returned raw [ColorScheme] participates in the built-in
/// property-access whitelist (see `resolveBuiltinProperty`), so downstream
/// source can read `.primary`, `.onPrimary`, etc. directly.
final class ColorSchemeFromSeedBuilder implements RuneValueBuilder {
  /// Const constructor - the builder is stateless.
  const ColorSchemeFromSeedBuilder();

  @override
  String get typeName => 'ColorScheme';

  @override
  String? get constructorName => 'fromSeed';

  @override
  ColorScheme build(ResolvedArguments args, RuneContext ctx) {
    return ColorScheme.fromSeed(
      seedColor: args.require<Color>(
        'seedColor',
        source: 'ColorScheme.fromSeed',
      ),
      brightness: args.getOr<Brightness>('brightness', Brightness.light),
    );
  }
}
