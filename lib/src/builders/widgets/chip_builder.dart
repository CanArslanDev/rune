import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [Chip] — compact info tag with an optional delete
/// affordance. Required `label` (Widget, typically Text). Optional
/// `avatar`, `onDeleted` (String event — triggers a delete X when set),
/// `deleteIcon`, `backgroundColor`, `labelStyle`.
final class ChipBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ChipBuilder();

  @override
  String get typeName => 'Chip';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final label = args.require<Widget>('label', source: 'Chip');
    return Chip(
      label: label,
      avatar: args.get<Widget>('avatar'),
      onDeleted: voidEventCallback(
        args.get<String>('onDeleted'),
        ctx.events,
      ),
      deleteIcon: args.get<Widget>('deleteIcon'),
      backgroundColor: args.get<Color>('backgroundColor'),
      labelStyle: args.get<TextStyle>('labelStyle'),
    );
  }
}
