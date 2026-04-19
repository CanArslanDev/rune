import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [Badge] — wraps an optional `child` with a small
/// overlay label (e.g. `Text('3')` for a notification count). All args
/// optional: `child`, `label`, `backgroundColor`, `textColor`,
/// `smallSize` (size when no label), `largeSize` (size when label
/// present), `isLabelVisible` (default true).
final class BadgeBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const BadgeBuilder();

  @override
  String get typeName => 'Badge';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Badge(
      label: args.get<Widget>('label'),
      backgroundColor: args.get<Color>('backgroundColor'),
      textColor: args.get<Color>('textColor'),
      smallSize: args.get<num>('smallSize')?.toDouble(),
      largeSize: args.get<num>('largeSize')?.toDouble(),
      isLabelVisible: args.getOr<bool>('isLabelVisible', true),
      child: args.get<Widget>('child'),
    );
  }
}
