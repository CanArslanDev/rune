import 'package:flutter/foundation.dart';

/// Routes named events from within Rune-built widgets to handlers registered
/// by the host app.
///
/// - Re-registering an event replaces the previous handler.
/// - Dispatching an unknown event emits a `debugPrint` warning and returns
///   without throwing — events are UI-triggered and should never crash a
///   render.
final class EventDispatcher {
  /// Constructs an [EventDispatcher] with no registered handlers.
  EventDispatcher();

  final Map<String, Function> _handlers = <String, Function>{};

  /// Installs [handler] under [name], replacing any previous registration.
  void register(String name, Function handler) {
    _handlers[name] = handler;
  }

  /// Invokes the handler registered under [name], forwarding [args]
  /// positionally. No-ops (with a warning) when no handler exists.
  void dispatch(String name, [List<Object?>? args]) {
    final Function? handler = _handlers[name];
    if (handler == null) {
      debugPrint('[rune] No handler registered for event "$name"');
      return;
    }
    Function.apply(handler, args ?? const <Object?>[]);
  }
}
