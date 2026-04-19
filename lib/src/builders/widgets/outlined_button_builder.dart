import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [OutlinedButton] - a button with a visible outline
/// and no fill. Commonly paired with [FilledButton] as a secondary
/// action on Material 3 surfaces.
///
/// Source arguments:
/// - `onPressed` (`String` event name or `RuneClosure`) - optional. A
///   missing or explicitly-null value leaves `OutlinedButton.onPressed`
///   null (disabled button).
/// - `child` ([Widget]?) - optional. Falls back to an empty `SizedBox`.
final class OutlinedButtonBuilder implements RuneWidgetBuilder {
  /// Const constructor - the builder is stateless.
  const OutlinedButtonBuilder();

  @override
  String get typeName => 'OutlinedButton';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return OutlinedButton(
      onPressed: voidEventCallback(args.named['onPressed'], ctx.events),
      child: args.get<Widget>('child') ?? const SizedBox.shrink(),
    );
  }
}
