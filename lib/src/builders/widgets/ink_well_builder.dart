import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [InkWell] — the same tap-wrapping pattern as
/// `GestureDetector` but with ink-splash feedback. Each `on*` argument
/// in source is a `String` event name that dispatches through
/// [RuneContext.events] with empty args on gesture.
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
    final onTapEvent = args.get<String>('onTap');
    final onDoubleTapEvent = args.get<String>('onDoubleTap');
    final onLongPressEvent = args.get<String>('onLongPress');
    return InkWell(
      onTap: onTapEvent == null
          ? null
          : () => ctx.events.dispatch(onTapEvent),
      onDoubleTap: onDoubleTapEvent == null
          ? null
          : () => ctx.events.dispatch(onDoubleTapEvent),
      onLongPress: onLongPressEvent == null
          ? null
          : () => ctx.events.dispatch(onLongPressEvent),
      borderRadius: args.get<BorderRadius>('borderRadius'),
      child: args.get<Widget>('child'),
    );
  }
}
