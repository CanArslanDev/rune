import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [DropdownButton] parametric on [Object?].
///
/// Source arguments:
/// - `items` (`List<DropdownMenuItem<Object?>>`) — required. Entries
///   that are not `DropdownMenuItem<Object?>` (including `null`) are
///   silently filtered out, matching the Column/Row children-filter
///   convention.
/// - `value` (any type) — optional; currently-selected value. Both
///   absent and explicit `null` render the dropdown in its "no
///   selection" state showing the `hint` widget.
/// - `onChanged` (`String?`) — optional event name; dispatches
///   `(eventName, [newValue])` through [RuneContext.events] on
///   selection. A missing `onChanged` leaves Flutter's slot `null`,
///   disabling the dropdown — same disabled-when-null pattern as
///   Switch / Checkbox / Slider / Radio.
/// - `hint` (`Widget?`) — placeholder shown when `value` is null.
/// - `disabledHint` (`Widget?`) — shown when the dropdown is disabled.
/// - `isExpanded` (`bool`) — defaults to `false`; stretches the button
///   to fill the available horizontal space.
///
/// The host owns selection state — same two-way binding contract as
/// the other form inputs: interactions fire named events carrying the
/// newly-selected value; the host updates its data map and re-renders.
final class DropdownButtonBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const DropdownButtonBuilder();

  @override
  String get typeName => 'DropdownButton';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawItems = args.require<List<Object?>>(
      'items',
      source: 'DropdownButton',
    );
    final items = rawItems.whereType<DropdownMenuItem<Object?>>().toList();
    return DropdownButton<Object?>(
      items: items,
      // `value` is legitimately optional and null; reading it directly
      // from the named map means absent and explicit-null both produce
      // null, which is what DropdownButton expects for "no selection".
      value: args.named['value'],
      onChanged: valueEventCallback<Object?>(
        args.get<String>('onChanged'),
        ctx.events,
      ),
      hint: args.get<Widget>('hint'),
      disabledHint: args.get<Widget>('disabledHint'),
      isExpanded: args.getOr<bool>('isExpanded', false),
    );
  }
}
