import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [ChoiceChip], a single-select chip. Required
/// `label` (Widget, typically Text) and `selected` (bool); optional
/// `onSelected` event name that dispatches `(eventName, [newBool])`
/// on tap, plus `avatar`, `backgroundColor`, `selectedColor`,
/// `labelStyle`.
final class ChoiceChipBuilder implements RuneWidgetBuilder {
  /// Const constructor; the builder is stateless.
  const ChoiceChipBuilder();

  @override
  String get typeName => 'ChoiceChip';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return ChoiceChip(
      label: args.require<Widget>('label', source: 'ChoiceChip'),
      selected: args.require<bool>('selected', source: 'ChoiceChip'),
      onSelected: valueEventCallback<bool>(
        args.get<String>('onSelected'),
        ctx.events,
      ),
      avatar: args.get<Widget>('avatar'),
      backgroundColor: args.get<Color>('backgroundColor'),
      selectedColor: args.get<Color>('selectedColor'),
      labelStyle: args.get<TextStyle>('labelStyle'),
    );
  }
}
