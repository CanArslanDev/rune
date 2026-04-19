import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [FloatingActionButton]. `onPressed` accepts a `String`
/// event name dispatched through [RuneContext.events]; a null `onPressed`
/// renders a disabled (greyed-out) FAB. Optional `child` (usually an
/// Icon), `tooltip`, `backgroundColor`, `foregroundColor`, `mini` (default
/// false).
final class FloatingActionButtonBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const FloatingActionButtonBuilder();

  @override
  String get typeName => 'FloatingActionButton';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return FloatingActionButton(
      onPressed: voidEventCallback(
        args.named['onPressed'],
        ctx.events,
      ),
      tooltip: args.get<String>('tooltip'),
      backgroundColor: args.get<Color>('backgroundColor'),
      foregroundColor: args.get<Color>('foregroundColor'),
      mini: args.getOr<bool>('mini', false),
      child: args.get<Widget>('child'),
    );
  }
}
