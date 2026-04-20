import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoThemeData], the value typically passed to
/// [CupertinoApp.theme] or a nested [CupertinoTheme].
///
/// Supported named arguments:
/// - `brightness` ([Brightness]?) - registered via
///   `Brightness.light` / `Brightness.dark` in the constant registry.
/// - `primaryColor` ([Color]?) - default primary tint.
/// - `primaryContrastingColor` ([Color]?) - contrasting tint used on
///   top of `primaryColor`.
/// - `scaffoldBackgroundColor` ([Color]?) - background for page-level
///   surfaces.
/// - `barBackgroundColor` ([Color]?) - background for nav bars and tab
///   bars.
final class CupertinoThemeDataBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoThemeDataBuilder();

  @override
  String get typeName => 'CupertinoThemeData';

  @override
  String? get constructorName => null;

  @override
  CupertinoThemeData build(ResolvedArguments args, RuneContext ctx) {
    return CupertinoThemeData(
      brightness: args.get<Brightness>('brightness'),
      primaryColor: args.get<Color>('primaryColor'),
      primaryContrastingColor: args.get<Color>('primaryContrastingColor'),
      scaffoldBackgroundColor: args.get<Color>('scaffoldBackgroundColor'),
      barBackgroundColor: args.get<Color>('barBackgroundColor'),
    );
  }
}
