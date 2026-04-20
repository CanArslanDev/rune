import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `DragTarget<Object>`. This is the drop surface that pairs with
/// [Draggable] / `LongPressDraggable`. The `builder:` argument is a
/// 3-arg closure `(BuildContext ctx, List candidateData,
/// List rejectedData) -> Widget` invoked on every frame so the target's
/// appearance can react to in-progress drags.
///
/// Event hooks `onAcceptWithDetails` and `onWillAcceptWithDetails`
/// accept either a `String` event name dispatched through
/// [RuneContext.events] (the [DragTargetDetails] arrives at `args[0]`),
/// or a single-parameter closure. `onWillAcceptWithDetails` closures
/// must return `bool`; a non-bool body raises a `ResolveException` at
/// invocation time. String handlers for the will-accept slot always
/// return `true` because there is no synchronous return path through
/// the dispatcher.
final class DragTargetBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const DragTargetBuilder();

  @override
  String get typeName => 'DragTarget';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final builder = toDragTargetBuilder(args.named['builder'], 'DragTarget');
    return DragTarget<Object>(
      builder: builder,
      onAcceptWithDetails: toDragAcceptCallback(
        args.named['onAcceptWithDetails'],
        'DragTarget',
        ctx.events,
      ),
      onWillAcceptWithDetails: toDragWillAcceptCallback(
        args.named['onWillAcceptWithDetails'],
        'DragTarget',
        ctx.events,
      ),
    );
  }
}
