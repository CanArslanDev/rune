// ignore_for_file: deprecated_member_use
//
// Rationale: Flutter 3.41 deprecated `Radio.groupValue` / `onChanged`
// in favour of a `RadioGroup` ancestor. The Rune source model pairs
// `value` + `groupValue` + `onChanged` at the source level, matching
// the pre-3.41 contract; migrating to `RadioGroup` would require every
// Rune-level radio tile to be wrapped in a `RadioGroup` source widget,
// which changes the user-facing API and loses the "one widget per
// invocation" simplicity. See [RadioBuilder]'s class dartdoc for the
// long-form discussion — this builder inherits the same deprecation
// posture for consistency.

import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [RadioListTile] — a [Radio] paired with a [ListTile]
/// layout. Parametric on `Object?` to accept any runtime identity (int,
/// String, enum-ish keys), matching [RadioBuilder]'s own contract.
///
/// Source arguments:
/// - `value` (any type) — required (presence-checked). `null` is a
///   legitimate radio identity, so the builder inspects the named map
///   directly rather than through [ResolvedArguments.require].
/// - `groupValue` (any type) — optional; the currently-selected identity
///   in the group. The tile renders selected when `value == groupValue`.
/// - `onChanged` (`String?`) — optional event name. Dispatches
///   `(eventName, [value])` on tap.
/// - `toggleable` (`bool`) — defaults to `false`. When `true`, tapping
///   the selected tile deselects it and dispatches
///   `(eventName, list-of-one-null)`.
/// - `title`, `subtitle`, `secondary` (`Widget?`) — optional layout slots.
/// - `controlAffinity` (`ListTileControlAffinity`) — defaults to
///   [ListTileControlAffinity.platform].
/// - `dense` (`bool?`) — optional.
/// - `activeColor` (`Color?`) — optional radio active tint.
final class RadioListTileBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const RadioListTileBuilder();

  @override
  String get typeName => 'RadioListTile';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    if (!args.named.containsKey('value')) {
      throw const ArgumentException(
        'RadioListTile',
        'Missing required argument "value"',
      );
    }
    // `value` and `groupValue` may legitimately be null for
    // RadioListTile<Object?>, so read them from the named map directly
    // rather than through `require`.
    final value = args.named['value'];
    final groupValue = args.named['groupValue'];
    return RadioListTile<Object?>(
      value: value,
      groupValue: groupValue,
      onChanged: valueEventCallback<Object?>(
        args.get<String>('onChanged'),
        ctx.events,
      ),
      toggleable: args.getOr<bool>('toggleable', false),
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
