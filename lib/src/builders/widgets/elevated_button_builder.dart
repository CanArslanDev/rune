import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ElevatedButton]. `onPressed` in source is a `String` event
/// name; the builder wraps it in a `VoidCallback` that dispatches via
/// `ctx.events`. A missing or explicitly-null `onPressed` leaves
/// `ElevatedButton.onPressed` as `null` (disabled button).
final class ElevatedButtonBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ElevatedButtonBuilder();

  @override
  String get typeName => 'ElevatedButton';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final eventName = args.get<String>('onPressed');
    final child = args.get<Widget>('child');
    return ElevatedButton(
      onPressed: eventName == null
          ? null
          : () => ctx.events.dispatch(eventName),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
