import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [Divider] — a thin horizontal line typically used
/// inside a Column. All args are optional; leaving them out gives
/// Flutter's own defaults.
final class DividerBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const DividerBuilder();

  @override
  String get typeName => 'Divider';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Divider(
      height: args.get<num>('height')?.toDouble(),
      thickness: args.get<num>('thickness')?.toDouble(),
      indent: args.get<num>('indent')?.toDouble(),
      endIndent: args.get<num>('endIndent')?.toDouble(),
      color: args.get<Color>('color'),
    );
  }
}
