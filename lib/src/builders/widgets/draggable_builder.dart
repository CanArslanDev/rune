import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Draggable<Object>`. Wraps a child widget so it can be
/// dragged toward a [DragTarget]. Source passes the payload through
/// `data:`, the always-visible widget through `child:`, and the
/// pointer-attached visual through `feedback:`.
///
/// The payload type is fixed at [Object] because Flutter's
/// `Draggable<T>` constrains `T extends Object` and Rune source has no
/// generic-type syntax. Null payloads are rejected by the upstream
/// framework contract, so a missing `data:` means the draggable
/// produces no data (matches Flutter's `T? data` semantics).
///
/// Event hooks (`onDragStarted`, `onDragEnd`) accept either a
/// `String` event name dispatched through [RuneContext.events], or a
/// closure. `onDragEnd` receives a single [DraggableDetails] argument.
final class DraggableBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const DraggableBuilder();

  @override
  String get typeName => 'Draggable';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Draggable<Object>(
      data: args.get<Object>('data'),
      feedback: args.require<Widget>('feedback', source: 'Draggable'),
      childWhenDragging: args.get<Widget>('childWhenDragging'),
      onDragStarted: voidEventCallback(
        args.named['onDragStarted'],
        ctx.events,
      ),
      onDragEnd: toDragEndCallback(args.named['onDragEnd'], 'Draggable'),
      child: args.require<Widget>('child', source: 'Draggable'),
    );
  }
}
