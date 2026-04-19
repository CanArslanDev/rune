import 'package:flutter/foundation.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';

/// Wraps a nullable source-level event name into a [VoidCallback] that
/// dispatches through [events] when invoked, or returns `null` when
/// [eventName] is `null` so the consuming Flutter widget sees a
/// disabled-style callback slot.
///
/// Used by builders whose Flutter widget accepts a no-arg callback
/// (e.g. `ElevatedButton.onPressed`, `GestureDetector.onTap`) and whose
/// Rune source supplies an optional `String` event name:
///
/// ```dart
/// onPressed: voidEventCallback(args.get<String>('onPressed'), ctx.events)
/// ```
///
/// The returned callback dispatches with an empty args list.
VoidCallback? voidEventCallback(
  String? eventName,
  RuneEventDispatcher events,
) {
  if (eventName == null) return null;
  return () => events.dispatch(eventName);
}

/// Wraps a nullable source-level event name into a [ValueChanged] of `T`
/// that dispatches through [events] with the callback's own value
/// forwarded as a single-element positional arg, or returns `null` when
/// [eventName] is `null`.
///
/// Used by builders whose Flutter widget accepts a value-carrying
/// callback (e.g. `Switch.onChanged`, `Slider.onChanged`) and whose Rune
/// source supplies an optional `String` event name. The callback's
/// runtime argument flows to the host through
/// `RuneView.onEvent(name, [value])`.
///
/// ```dart
/// onChanged: valueEventCallback<bool>(
///   args.get<String>('onChanged'),
///   ctx.events,
/// )
/// ```
ValueChanged<T>? valueEventCallback<T>(
  String? eventName,
  RuneEventDispatcher events,
) {
  if (eventName == null) return null;
  return (value) => events.dispatch(eventName, <Object?>[value]);
}
