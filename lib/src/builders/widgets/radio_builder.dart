import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [Radio] keyed by `value`. When the user taps,
/// dispatches `(onChanged, [value])` so the host knows which radio
/// button was selected and can set `groupValue` in its own state map.
///
/// Parametric on `Object?` to accept any runtime identity (int,
/// String, enum-ish keys). `groupValue` compares with `==`; the
/// button renders selected when `value == groupValue`.
///
/// Source arguments:
/// - `value` (any type) — required; this radio button's own identity.
///   Unlike [ResolvedArguments]'s `require`, `null` is a valid Radio
///   value — so this builder checks for *presence* of the key, not
///   nullability of the value.
/// - `groupValue` (any type) — optional; the currently-selected
///   identity in the group.
/// - `onChanged` (`String?`) — optional event name; dispatches
///   `(eventName, [value])` on tap. A missing `onChanged` leaves
///   the radio's callback `null`, disabling interaction.
/// - `toggleable` (`bool`) — optional; defaults to `false`. When
///   `true`, tapping a selected radio deselects it and dispatches
///   `(eventName, list-of-one-null)`.
///
/// Note: Flutter deprecated [Radio]'s `groupValue` and `onChanged` in
/// favour of a `RadioGroup` ancestor after v3.32.0-0.0.pre. Rune
/// intentionally keeps the direct-argument contract so radio buttons
/// can be declared standalone in source — the host owns `groupValue`
/// in its data map and dispatches updates through the event channel,
/// matching the two-way binding pattern used by other form inputs.
final class RadioBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const RadioBuilder();

  @override
  String get typeName => 'Radio';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    if (!args.named.containsKey('value')) {
      throw const ArgumentException(
        'Radio',
        'Missing required argument "value"',
      );
    }
    // `value` may legitimately be null for Radio<Object?>, so read it
    // from the named map directly rather than through `require`.
    final value = args.named['value'];
    final groupValue = args.named['groupValue'];
    final eventName = args.get<String>('onChanged');
    final toggleable = args.getOr<bool>('toggleable', false);
    // See class dartdoc: Rune intentionally keeps the direct
    // groupValue/onChanged contract rather than requiring a RadioGroup
    // ancestor in source. The deprecated members are still supported in
    // Flutter 3.41 and continue to work as documented; the suppressions
    // below acknowledge the deprecation without altering the contract.
    return Radio<Object?>(
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      toggleable: toggleable,
      // ignore: deprecated_member_use
      onChanged: eventName == null
          ? null
          : (next) => ctx.events.dispatch(eventName, <Object?>[next]),
    );
  }
}
