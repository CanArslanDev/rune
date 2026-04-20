import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Signature of a handler that implements a Rune-source-level imperative
/// call.
///
/// Handlers receive [ResolvedArguments] shaped exactly the same way a
/// widget or value builder would receive them (the resolver resolves the
/// argument list before dispatch) plus the ambient [RuneContext]. The
/// return value becomes the Dart result of the invocation expression in
/// source, so a handler for `navigator.push(route)` might return the
/// future that completes when the route pops.
typedef ImperativeHandler = Object? Function(
  ResolvedArguments args,
  RuneContext ctx,
);

/// A registry of source-level imperative bridges.
///
/// Rune source can invoke two shapes of imperative:
///
/// - **Bare calls**: `showDialog(...)`, `showSnackBar(snackBar)`,
///   `showMenu(position: rect, items: entries)`. Keyed by the method
///   name alone.
/// - **Prefixed calls**: `Navigator.pop(result)`, `Navigator.push(route)`,
///   `Router.go('/path')`. Keyed by `(target, method)` where `target` is
///   the identifier before the dot.
///
/// The main `rune` package ships a hardcoded set of built-in imperatives
/// (Flutter's modal/overlay APIs and `Navigator.*`). Sibling bridges can
/// add more through this registry: `rune_router`, for instance, can
/// register `Router.go(path)` without the main package needing to know
/// about go_router.
///
/// The resolver consults the registry **before** the hardcoded built-ins
/// so a host that wants to shadow a default (e.g. swap Flutter's
/// `showDialog` for a custom implementation) can do so by registering a
/// handler under the same name.
///
/// Duplicate registrations within the registry raise [StateError] at
/// registration time, matching the behavior of the other Rune registries.
final class ImperativeRegistry {
  /// Creates an empty imperative registry.
  ImperativeRegistry();

  final Map<String, ImperativeHandler> _bare = <String, ImperativeHandler>{};
  final Map<String, Map<String, ImperativeHandler>> _prefixed =
      <String, Map<String, ImperativeHandler>>{};

  /// Registers [handler] to execute when Rune source contains a bare
  /// [name] call (e.g. `showToast(message: 'hi')`).
  ///
  /// Throws [StateError] if [name] is already registered.
  void registerBare(String name, ImperativeHandler handler) {
    if (_bare.containsKey(name)) {
      throw StateError(
        'ImperativeRegistry already contains a bare imperative "$name". '
        'Use a distinct name or deregister the old handler first.',
      );
    }
    _bare[name] = handler;
  }

  /// Registers [handler] to execute when Rune source contains
  /// `target.method(...)` (e.g. `Router.go('/path')`).
  ///
  /// Throws [StateError] if the exact `(target, method)` pair is already
  /// registered.
  void registerPrefixed(
    String target,
    String method,
    ImperativeHandler handler,
  ) {
    final byMethod = _prefixed.putIfAbsent(
      target,
      () => <String, ImperativeHandler>{},
    );
    if (byMethod.containsKey(method)) {
      throw StateError(
        'ImperativeRegistry already contains a prefixed imperative '
        '"$target.$method". Use a distinct method name or deregister the '
        'old handler first.',
      );
    }
    byMethod[method] = handler;
  }

  /// Returns the handler registered under the bare name [name], or
  /// `null` if absent.
  ImperativeHandler? findBare(String name) => _bare[name];

  /// Returns the handler registered under `target.method`, or `null`
  /// if absent.
  ImperativeHandler? findPrefixed(String target, String method) =>
      _prefixed[target]?[method];

  /// Iterable view of every registered bare imperative name. Used by
  /// the resolver to compute `did-you-mean` suggestions on miss.
  Iterable<String> get bareNames => _bare.keys;

  /// Iterable view of every registered prefixed-target name. Used by
  /// the resolver to compute `did-you-mean` suggestions on miss.
  Iterable<String> get prefixedTargets => _prefixed.keys;

  /// Iterable view of methods registered under [target]. Returns an
  /// empty iterable if [target] has no registrations.
  Iterable<String> methodsFor(String target) =>
      _prefixed[target]?.keys ?? const <String>[];
}
