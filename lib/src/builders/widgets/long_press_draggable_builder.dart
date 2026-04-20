import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `LongPressDraggable<Object>`. Identical shape to
/// [Draggable], except the drag only starts after a long press. Useful
/// inside scrollable surfaces where an immediate drag would fight the
/// scroll gesture.
///
/// Accepts the same arguments as [Draggable]: `data`, `child`,
/// `feedback`, `childWhenDragging`, `onDragStarted`, `onDragEnd`.
final class LongPressDraggableBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const LongPressDraggableBuilder();

  @override
  String get typeName => 'LongPressDraggable';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return LongPressDraggable<Object>(
      data: args.get<Object>('data'),
      feedback: args.require<Widget>(
        'feedback',
        source: 'LongPressDraggable',
      ),
      childWhenDragging: args.get<Widget>('childWhenDragging'),
      onDragStarted: voidEventCallback(
        args.named['onDragStarted'],
        ctx.events,
      ),
      onDragEnd: toDragEndCallback(
        args.named['onDragEnd'],
        'LongPressDraggable',
      ),
      child: args.require<Widget>('child', source: 'LongPressDraggable'),
    );
  }
}
