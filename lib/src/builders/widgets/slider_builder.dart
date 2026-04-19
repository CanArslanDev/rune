import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [Slider] with value-change dispatch.
///
/// Source arguments:
/// - `value` (`num`) — required; coerced to `double`. Current slider
///   position.
/// - `min` (`num`) — optional; defaults to `0.0`. Coerced to `double`.
/// - `max` (`num`) — optional; defaults to `1.0`. Coerced to `double`.
/// - `divisions` (`int?`) — optional; when set, the slider snaps to
///   discrete values.
/// - `label` (`String?`) — optional value-overlay label shown on drag
///   (requires `divisions` or a discrete theme to be visible).
/// - `onChanged` (`String?`) — optional event name; dispatches
///   `(eventName, [newDouble])` through `RuneContext.events` on drag.
///   A missing `onChanged` leaves the slider's callback `null`, which
///   disables it.
///
/// The host owns state: each drag dispatches the new value so the
/// host can update `value` in its data map and re-render. This mirrors
/// the two-way binding contract used by `TextField`/`Switch`/`Checkbox`.
final class SliderBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SliderBuilder();

  @override
  String get typeName => 'Slider';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Slider(
      value: args.require<num>('value', source: 'Slider').toDouble(),
      min: args.get<num>('min')?.toDouble() ?? 0.0,
      max: args.get<num>('max')?.toDouble() ?? 1.0,
      divisions: args.get<int>('divisions'),
      label: args.get<String>('label'),
      onChanged: valueEventCallback<double>(
        args.get<String>('onChanged'),
        ctx.events,
      ),
    );
  }
}
