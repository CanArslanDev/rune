import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [CircularProgressIndicator]. All args optional: no
/// args renders the default indeterminate spinner. `value` (num, null =
/// indeterminate; 0.0–1.0 = determinate), `color`, `backgroundColor`,
/// `strokeWidth` (default 4.0).
final class CircularProgressIndicatorBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const CircularProgressIndicatorBuilder();

  @override
  String get typeName => 'CircularProgressIndicator';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return CircularProgressIndicator(
      value: args.get<num>('value')?.toDouble(),
      color: args.get<Color>('color'),
      backgroundColor: args.get<Color>('backgroundColor'),
      strokeWidth: args.get<num>('strokeWidth')?.toDouble() ?? 4.0,
    );
  }
}
