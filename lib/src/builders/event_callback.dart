import 'package:flutter/foundation.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/resolver/rune_closure.dart';

/// Wraps a nullable source-level event source into a [VoidCallback] that
/// fires when the underlying Flutter widget reports a no-arg gesture, or
/// returns `null` when [source] is `null` so the consuming widget sees a
/// disabled-style callback slot.
///
/// The [source] argument accepts two runtime shapes, matching the two
/// ways a Rune source expression can bind an event:
///
/// 1. A `String` event name: the callback dispatches through [events]
///    as `events.dispatch(name, <empty>)`. This is the Phase 2d named-
///    event path; unchanged from earlier phases.
/// 2. A [RuneClosure]: the callback invokes `source.call(<empty>)`,
///    evaluating the closure's body against its captured context. The
///    return value is discarded (Flutter's [VoidCallback] returns
///    `void`). This is the Phase A.2 closure path.
///
/// Any other runtime type raises [ResolveException] citing the helper
/// contract. `null` in, `null` out, always.
///
/// ```dart
/// onPressed: voidEventCallback(args.named['onPressed'], ctx.events)
/// ```
VoidCallback? voidEventCallback(
  Object? source,
  RuneEventDispatcher events,
) {
  if (source == null) return null;
  if (source is String) {
    final eventName = source;
    return () => events.dispatch(eventName);
  }
  if (source is RuneClosure) {
    final closure = source;
    return () => closure.call(const <Object?>[]);
  }
  throw ResolveException(
    source.toString(),
    'onPressed / onTap accepts a String event name or a closure '
    '(e.g. () => ...); got ${source.runtimeType}',
  );
}

/// Wraps a nullable source-level event source into a [ValueChanged] of
/// `T` that forwards the Flutter callback's own value, or returns
/// `null` when [source] is `null` so the consuming widget sees a
/// disabled-style callback slot.
///
/// The [source] argument accepts two runtime shapes, matching the two
/// ways a Rune source expression can bind a value-carrying event:
///
/// 1. A `String` event name: the callback dispatches through [events]
///    as `events.dispatch(name, [value])`. The value arrives in the
///    host's `onEvent(name, args)` handler at `args[0]`.
/// 2. A [RuneClosure]: the callback invokes `source.call([value])`,
///    evaluating the closure's body against its captured context
///    extended with the closure's single declared parameter bound to
///    the forwarded value. The return value is discarded (Flutter's
///    [ValueChanged] returns `void`).
///
/// Any other runtime type raises [ResolveException].
///
/// ```dart
/// onChanged: valueEventCallback<bool>(
///   args.named['onChanged'],
///   ctx.events,
/// )
/// ```
ValueChanged<T>? valueEventCallback<T>(
  Object? source,
  RuneEventDispatcher events,
) {
  if (source == null) return null;
  if (source is String) {
    final eventName = source;
    return (value) => events.dispatch(eventName, <Object?>[value]);
  }
  if (source is RuneClosure) {
    final closure = source;
    return (value) => closure.call(<Object?>[value]);
  }
  throw ResolveException(
    source.toString(),
    'onChanged / onSelected accepts a String event name or a closure '
    '(e.g. (v) => ...); got ${source.runtimeType}',
  );
}
