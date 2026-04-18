import 'package:flutter/foundation.dart';

/// Routes named events from within Rune-built widgets to handlers registered
/// by the host app.
///
/// - Re-registering an event replaces the previous handler.
/// - Dispatching an unknown event emits a `debugPrint` warning and returns
///   without throwing — events are UI-triggered and should never crash a
///   render.
/// - If the handler itself throws (including `NoSuchMethodError` from an
///   arity mismatch between the registered function and the forwarded
///   arguments), the exception is caught and logged via `debugPrint`.
///   Dispatch still returns normally.
/// - Async handlers' returned `Future`s are **not awaited**. Any errors
///   those futures produce asynchronously are suppressed and not observable
///   via this class — prefer synchronous handlers, or bubble async work
///   into your own error-handling infrastructure.
final class RuneEventDispatcher {
  /// Constructs a [RuneEventDispatcher] with no registered handlers.
  RuneEventDispatcher();

  final Map<String, Function> _handlers = <String, Function>{};

  /// Installs [handler] under [name], replacing any previous registration.
  void register(String name, Function handler) {
    _handlers[name] = handler;
  }

  /// Invokes the handler registered under [name], forwarding [args]
  /// positionally.
  ///
  /// No-ops (with a warning) when no handler exists. Any exception raised
  /// inside the handler — including argument-count mismatches — is caught
  /// and logged; [dispatch] never rethrows.
  void dispatch(String name, [List<Object?>? args]) {
    final Function? handler = _handlers[name];
    if (handler == null) {
      debugPrint('[rune] No handler registered for event "$name"');
      return;
    }
    try {
      Function.apply(handler, args ?? const <Object?>[]);
    } catch (error, stack) {
      debugPrint(
        '[rune] Error dispatching event "$name": $error\n$stack',
      );
    }
  }
}
