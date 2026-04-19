import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [CheckboxListTile] — a [Checkbox] paired with a
/// [ListTile] layout (`title`, `subtitle`, `secondary`, `controlAffinity`).
///
/// Source arguments:
/// - `value` (`bool?`) — required (presence-checked). `null` is legitimate
///   when `tristate: true`, so the builder inspects the named map directly
///   rather than through [ResolvedArguments.require], matching the
///   absence-vs-explicit-null discrimination in `CheckboxBuilder` /
///   `RadioBuilder`.
/// - `onChanged` (`String?`) — optional event name. Dispatches
///   `(eventName, [bool?])` on tap. A missing `onChanged` leaves the
///   underlying Flutter callback `null`, disabling the tile.
/// - `title`, `subtitle`, `secondary` (`Widget?`) — optional layout slots.
/// - `tristate` (`bool`) — defaults to `false`.
/// - `controlAffinity` (`ListTileControlAffinity`) — defaults to
///   [ListTileControlAffinity.platform].
/// - `dense` (`bool?`) — optional.
/// - `activeColor` (`Color?`) — optional checkbox active tint.
final class CheckboxListTileBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const CheckboxListTileBuilder();

  @override
  String get typeName => 'CheckboxListTile';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    if (!args.named.containsKey('value')) {
      throw const ArgumentException(
        'CheckboxListTile',
        'Missing required argument "value"',
      );
    }
    // `value` may legitimately be null under tristate, so read it from the
    // named map directly rather than through `require`.
    final value = args.named['value'] as bool?;
    return CheckboxListTile(
      value: value,
      onChanged: valueEventCallback<bool?>(
        args.get<String>('onChanged'),
        ctx.events,
      ),
      title: args.get<Widget>('title'),
      subtitle: args.get<Widget>('subtitle'),
      secondary: args.get<Widget>('secondary'),
      tristate: args.getOr<bool>('tristate', false),
      controlAffinity: args.getOr<ListTileControlAffinity>(
        'controlAffinity',
        ListTileControlAffinity.platform,
      ),
      dense: args.get<bool>('dense'),
      activeColor: args.get<Color>('activeColor'),
    );
  }
}
