// ignore_for_file: deprecated_member_use
//
// Rationale: Flutter 3.31 deprecated `SwitchListTile.activeColor` in
// favour of `activeThumbColor` / `activeTrackColor`. Rune exposes
// `activeColor` at the source level to match `SwitchBuilder` and the
// pre-3.31 contract; upgrading would split a single source-level knob
// into two, breaking existing `RuneView` source strings. The underlying
// tint still works as documented.

import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [SwitchListTile] — a [Switch] paired with a [ListTile]
/// layout. Unlike [CheckboxListTile], [Switch] is not tristate, so `value`
/// is a non-null `bool`.
///
/// Source arguments:
/// - `value` (`bool`) — required non-null.
/// - `onChanged` (`String?`) — optional event name. Dispatches
///   `(eventName, [bool])` on tap.
/// - `title`, `subtitle`, `secondary` (`Widget?`) — optional layout slots.
/// - `controlAffinity` (`ListTileControlAffinity`) — defaults to
///   [ListTileControlAffinity.platform].
/// - `dense` (`bool?`) — optional.
/// - `activeColor` (`Color?`) — optional switch active tint.
final class SwitchListTileBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SwitchListTileBuilder();

  @override
  String get typeName => 'SwitchListTile';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return SwitchListTile(
      value: args.require<bool>('value', source: 'SwitchListTile'),
      onChanged: valueEventCallback<bool>(
        args.get<String>('onChanged'),
        ctx.events,
      ),
      title: args.get<Widget>('title'),
      subtitle: args.get<Widget>('subtitle'),
      secondary: args.get<Widget>('secondary'),
      controlAffinity: args.getOr<ListTileControlAffinity>(
        'controlAffinity',
        ListTileControlAffinity.platform,
      ),
      dense: args.get<bool>('dense'),
      activeColor: args.get<Color>('activeColor'),
    );
  }
}
