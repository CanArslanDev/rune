import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoActivityIndicator]. All args optional.
///
/// Source arguments:
/// - `animating` (`bool`) - defaults to `true`. When `false`, draws a
///   static snapshot of the spinner.
/// - `radius` (`num`) - defaults to 10.0. Coerced to `double`. Must be
///   greater than zero per Flutter's own assertion.
/// - `color` ([Color]?) - override the default tint.
final class CupertinoActivityIndicatorBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoActivityIndicatorBuilder();

  @override
  String get typeName => 'CupertinoActivityIndicator';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return CupertinoActivityIndicator(
      animating: args.getOr<bool>('animating', true),
      radius: args.get<num>('radius')?.toDouble() ?? 10.0,
      color: args.get<Color>('color'),
    );
  }
}
