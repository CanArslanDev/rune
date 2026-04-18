import 'package:flutter/foundation.dart';

/// Routes named events from within Rune-built widgets to handlers registered
/// by the host app.
///
/// - Re-registering an event replaces the previous handler.
/// - Dispatching an unknown event emits a `debugPrint` warning and returns
///   without throwing — events are UI-triggered and should never crash a
///   render. The warning is suppressed when a catch-all handler is
///   installed (it is presumed to handle the event).
/// - A single catch-all handler (see [setCatchAllHandler]) fires on every
///   dispatch in addition to any matching named handler.
/// - If the handler itself throws (including `NoSuchMethodError` from an
///   arity mismatch between the registered function and the forwarded
///   arguments), the exception is caught and logged via `debugPrint`.
///   Dispatch still returns normally.
/// - Async handlers' returned `Future`s are **not awaited**. Any errors
///   those futures produce asynchronously are suppressed and not observable
///   via this class — prefer synchronous handlers, or bubble async work
///   into your own error-handling infrastructure.
final class RuneEventDispatcher {
  /// Constructs a [RuneEventDispatcher] with no registered handlers and no
  /// catch-all.
  RuneEventDispatcher();

  final Map<String, Function> _handlers = <String, Function>{};
  void Function(String name, List<Object?> args)? _catchAll;

  /// Installs [handler] under [name], replacing any previous registration.
  void register(String name, Function handler) {
    _handlers[name] = handler;
  }

  /// Installs [handler] as a catch-all invoked on every [dispatch]. Pass
  /// `null` to clear. Typically used by `RuneView` to bridge its `onEvent`
  /// callback to the dispatcher so source-declared events like
  /// `onPressed: "submit"` reach the host app.
  void setCatchAllHandler(
    void Function(String name, List<Object?> args)? handler,
  ) {
    _catchAll = handler;
  }

  /// Invokes the catch-all (if set) and the handler registered under [name]
  /// (if any), forwarding [args] positionally.
  ///
  /// No-ops (with a warning) when neither a named handler nor a catch-all
  /// exists. Any exception raised inside either handler — including
  /// argument-count mismatches — is caught and logged; [dispatch] never
  /// rethrows.
  void dispatch(String name, [List<Object?>? args]) {
    final List<Object?> argsList = args ?? const <Object?>[];
    final catchAll = _catchAll;
    if (catchAll != null) {
      try {
        catchAll(name, argsList);
      } catch (error, stack) {
        debugPrint(
          '[rune] Catch-all handler error on "$name": $error\n$stack',
        );
      }
    }
    final Function? handler = _handlers[name];
    if (handler == null) {
      if (catchAll == null) {
        debugPrint('[rune] No handler registered for event "$name"');
      }
      return;
    }
    try {
      Function.apply(handler, argsList);
    } catch (error, stack) {
      debugPrint(
        '[rune] Error dispatching event "$name": $error\n$stack',
      );
    }
  }
}
