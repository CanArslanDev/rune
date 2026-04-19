import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [FilterChip], a multi-select toggle chip.
/// Required `label` (Widget, typically Text) and `selected` (bool);
/// optional `onSelected` event name that dispatches
/// `(eventName, [newBool])` on tap, plus `avatar`, `backgroundColor`,
/// `selectedColor`, `checkmarkColor`, `showCheckmark` (default true),
/// `labelStyle`.
final class FilterChipBuilder implements RuneWidgetBuilder {
  /// Const constructor; the builder is stateless.
  const FilterChipBuilder();

  @override
  String get typeName => 'FilterChip';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return FilterChip(
      label: args.require<Widget>('label', source: 'FilterChip'),
      selected: args.require<bool>('selected', source: 'FilterChip'),
      onSelected: valueEventCallback<bool>(
        args.get<String>('onSelected'),
        ctx.events,
      ),
      avatar: args.get<Widget>('avatar'),
      backgroundColor: args.get<Color>('backgroundColor'),
      selectedColor: args.get<Color>('selectedColor'),
      checkmarkColor: args.get<Color>('checkmarkColor'),
      showCheckmark: args.getOr<bool>('showCheckmark', true),
      labelStyle: args.get<TextStyle>('labelStyle'),
    );
  }
}
