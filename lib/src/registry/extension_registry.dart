import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/source_span.dart';

/// The signature every extension handler implements: take the resolved
/// target value and the current context, return whatever the property
/// accessor should evaluate to (e.g., for `10.w`, return the pixel width
/// computed from the screen size held in `ctx.flutterContext`).
typedef RuneExtensionHandler = Object? Function(
  Object? target,
  RuneContext ctx,
);

/// A registry of named extension handlers keyed by property name.
///
/// Phase 3a seeds this via `RuneBridge`s that register handlers for
/// `.w`, `.h`, `.px`, etc. The registry makes no assumption about the
/// target type — handlers downcast at the call site and should throw a
/// descriptive [ResolveException] on type mismatch.
final class ExtensionRegistry {
  /// Constructs an empty [ExtensionRegistry].
  ExtensionRegistry();

  final Map<String, RuneExtensionHandler> _handlers =
      <String, RuneExtensionHandler>{};

  /// Installs [handler] under [propertyName]. Throws [StateError] on
  /// duplicate.
  void register(String propertyName, RuneExtensionHandler handler) {
    if (_handlers.containsKey(propertyName)) {
      throw StateError(
        '$runtimeType already contains a handler for ".$propertyName". '
        'Use a distinct property name or remove the prior registration.',
      );
    }
    _handlers[propertyName] = handler;
  }

  /// Whether a handler is registered under [propertyName].
  bool contains(String propertyName) => _handlers.containsKey(propertyName);

  /// Invokes the handler for [propertyName] with [target] + [ctx], or
  /// returns `null` if the property is unknown.
  Object? resolve(String propertyName, Object? target, RuneContext ctx) {
    final handler = _handlers[propertyName];
    if (handler == null) return null;
    return handler(target, ctx);
  }

  /// Invokes the handler for [propertyName] with [target] + [ctx], or
  /// throws [ResolveException] citing [source] if the property is unknown.
  ///
  /// [location] is an optional [SourceSpan] pointing into the Rune source
  /// where the offending property access sits. Resolver callers thread one
  /// through; non-resolver callers may omit it.
  Object? require(
    String propertyName,
    Object? target,
    RuneContext ctx, {
    required String source,
    SourceSpan? location,
  }) {
    final handler = _handlers[propertyName];
    if (handler == null) {
      throw ResolveException(
        source,
        'Unknown extension property ".$propertyName"',
        location: location,
      );
    }
    return handler(target, ctx);
  }

  /// Number of registered handlers.
  int get size => _handlers.length;

  /// Iterable view of every registered extension property name. Used
  /// by `PropertyResolver` throw sites for "did you mean ...?"
  /// suggestions.
  Iterable<String> get names => _handlers.keys;
}
