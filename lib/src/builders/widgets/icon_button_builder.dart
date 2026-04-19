import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [IconButton] from a required `icon` widget, an optional
/// `onPressed` string (wrapped into a dispatcher closure; missing →
/// disabled), and optional `iconSize` (num) and `color`.
final class IconButtonBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const IconButtonBuilder();

  @override
  String get typeName => 'IconButton';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return IconButton(
      onPressed: voidEventCallback(args.named['onPressed'], ctx.events),
      icon: args.require<Widget>('icon', source: 'IconButton'),
      iconSize: args.get<num>('iconSize')?.toDouble(),
      color: args.get<Color>('color'),
    );
  }
}
