import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [GestureDetector] — wraps any child widget with discrete tap
/// event handlers. Each `on*` argument in source is either a `String`
/// event name or a closure; the handler dispatches through
/// [RuneContext.events] with empty args on gesture, or invokes the
/// closure's body.
///
/// Supported callbacks: `onTap`, `onDoubleTap`, `onLongPress`. Pointer-
/// carrying callbacks (`onPanUpdate`, `onScaleUpdate`, etc.) are out of
/// scope — they would require non-trivial pointer-event serialization
/// across the dispatch boundary.
final class GestureDetectorBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const GestureDetectorBuilder();

  @override
  String get typeName => 'GestureDetector';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return GestureDetector(
      onTap: voidEventCallback(args.named['onTap'], ctx.events),
      onDoubleTap: voidEventCallback(
        args.named['onDoubleTap'],
        ctx.events,
      ),
      onLongPress: voidEventCallback(
        args.named['onLongPress'],
        ctx.events,
      ),
      child: args.get<Widget>('child'),
    );
  }
}
