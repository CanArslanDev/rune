import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
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
    final eventName = args.get<String>('onPressed');
    final icon = args.require<Widget>('icon', source: 'IconButton');
    return IconButton(
      onPressed: eventName == null
          ? null
          : () => ctx.events.dispatch(eventName),
      icon: icon,
      iconSize: args.get<num>('iconSize')?.toDouble(),
      color: args.get<Color>('color'),
    );
  }
}
