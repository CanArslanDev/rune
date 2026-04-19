import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [LinearProgressIndicator]. All args optional: no args
/// renders the default indeterminate bar. `value` (num, null =
/// indeterminate; 0.0–1.0 = determinate), `color`, `backgroundColor`,
/// `minHeight`.
final class LinearProgressIndicatorBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const LinearProgressIndicatorBuilder();

  @override
  String get typeName => 'LinearProgressIndicator';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return LinearProgressIndicator(
      value: args.get<num>('value')?.toDouble(),
      color: args.get<Color>('color'),
      backgroundColor: args.get<Color>('backgroundColor'),
      minHeight: args.get<num>('minHeight')?.toDouble(),
    );
  }
}
