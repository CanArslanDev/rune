import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Tooltip] — attaches a long-press (mobile) or hover
/// (desktop) hint to its optional `child`.
///
/// Required named arg: `message` ([String]). Optional named args:
/// `preferBelow` ([bool], default `true`), `waitDuration`
/// ([Duration]), `showDuration` ([Duration]), `padding`
/// ([EdgeInsetsGeometry]).
///
/// Tooltip's `richMessage` ([InlineSpan]) slot is deferred —
/// `InlineSpan` is not currently in Rune's value-builder surface.
final class TooltipBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const TooltipBuilder();

  @override
  String get typeName => 'Tooltip';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Tooltip(
      message: args.require<String>('message', source: 'Tooltip'),
      preferBelow: args.getOr<bool>('preferBelow', true),
      waitDuration: args.get<Duration>('waitDuration'),
      showDuration: args.get<Duration>('showDuration'),
      padding: args.get<EdgeInsetsGeometry>('padding'),
      child: args.get<Widget>('child'),
    );
  }
}
