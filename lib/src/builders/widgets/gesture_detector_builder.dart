import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [GestureDetector] — wraps any child widget with discrete tap
/// event handlers. Each `on*` argument in source is a `String` event
/// name that dispatches through [RuneContext.events] with empty args
/// on gesture.
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
    final onTapEvent = args.get<String>('onTap');
    final onDoubleTapEvent = args.get<String>('onDoubleTap');
    final onLongPressEvent = args.get<String>('onLongPress');
    return GestureDetector(
      onTap: onTapEvent == null
          ? null
          : () => ctx.events.dispatch(onTapEvent),
      onDoubleTap: onDoubleTapEvent == null
          ? null
          : () => ctx.events.dispatch(onDoubleTapEvent),
      onLongPress: onLongPressEvent == null
          ? null
          : () => ctx.events.dispatch(onLongPressEvent),
      child: args.get<Widget>('child'),
    );
  }
}
