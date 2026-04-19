import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [InkWell] — the same tap-wrapping pattern as
/// `GestureDetector` but with ink-splash feedback. Each `on*` argument
/// in source is either a `String` event name or a closure; the handler
/// dispatches through [RuneContext.events] with empty args on gesture,
/// or invokes the closure's body.
///
/// Supported callbacks: `onTap`, `onDoubleTap`, `onLongPress`. Optional
/// `borderRadius` shapes the splash to match a rounded container.
///
/// `InkWell` needs a `Material` ancestor (typically provided by
/// `Scaffold` or an explicit `Material` widget) to render its ink
/// splash.
final class InkWellBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const InkWellBuilder();

  @override
  String get typeName => 'InkWell';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return InkWell(
      onTap: voidEventCallback(args.named['onTap'], ctx.events),
      onDoubleTap: voidEventCallback(
        args.named['onDoubleTap'],
        ctx.events,
      ),
      onLongPress: voidEventCallback(
        args.named['onLongPress'],
        ctx.events,
      ),
      borderRadius: args.get<BorderRadius>('borderRadius'),
      child: args.get<Widget>('child'),
    );
  }
}
