import 'package:rune/src/core/rune_context.dart';

/// Signature of a user-registered property accessor on an arbitrary
/// runtime type.
///
/// Called by `PropertyResolver` after the built-in property whitelist
/// misses, so a host that registered (via
/// `config.members.registerProperty<MyType>(...)`) can expose specific
/// fields of [target] to Rune source without taking a dependency on
/// `dart:mirrors`.
typedef MemberPropertyAccessor = Object? Function(
  Object target,
  RuneContext ctx,
);

/// Signature of a user-registered method invoker on an arbitrary
/// runtime type.
///
/// Called by `InvocationResolver._dispatchRuntimeMethod` after the
/// built-in method whitelist misses. [positionalArgs] holds the
/// source-side positional arguments pre-resolved by the expression
/// resolver; named arguments are NOT supported at the runtime-method
/// boundary (matching the built-in method policy).
typedef MemberMethodInvoker = Object? Function(
  Object target,
  List<Object?> positionalArgs,
  RuneContext ctx,
);

/// A registry of user-declared properties and methods on arbitrary
/// runtime types.
///
/// Rune ships a closed whitelist of members reachable on ordinary
/// runtime values (`String.length`, `List.contains`, `ThemeData.
/// colorScheme`, etc.) enumerated in `builtin_members.dart`. Any
/// member NOT on that whitelist surfaces as `ResolveException` at
/// resolve time: this is the store-review-compliance backbone (no
/// reflection, no `dart:mirrors`).
///
/// [MemberRegistry] gives hosts and sibling bridges a way to *extend*
/// the whitelist with their own types, keeping the store-review
/// posture (every reachable member is still explicitly registered)
/// while removing the need to either fork the main package or route
/// fields through `Map`-shaped projections (the v1.13 pattern used by
/// `rune_provider`'s `RuneReactiveNotifier.state` getter).
///
/// Typical usage from a host:
///
/// ```dart
/// class CounterNotifier extends ChangeNotifier {
///   int _count = 0;
///   int get count => _count;
///   void increment() {
///     _count++;
///     notifyListeners();
///   }
/// }
///
/// final config = RuneConfig.defaults();
/// config.members
///   ..registerProperty<CounterNotifier>('count', (t, _) => t.count)
///   ..registerMethod<CounterNotifier>('increment', (t, args, _) {
///     t.increment();
///     return null;
///   });
/// ```
///
/// After this, Rune source can write `counter.count` and
/// `counter.increment()` directly.
///
/// **Matching semantics.** `registerProperty<T>(...)` and
/// `registerMethod<T>(...)` use `is T` to test a runtime value, so a
/// subtype of the registered type is also matched (registering on
/// `ChangeNotifier` covers every concrete subclass). When multiple
/// registrations match the same name on the same target, **the first
/// registration wins** (registration order is stable).
///
/// **Priority.** For properties, the resolver consults the built-in
/// whitelist first; the registry fills the gap on miss, so stock
/// types (`String.length`, `List.first`, `ThemeData.colorScheme`)
/// cannot be shadowed by a user registration. For methods, the same
/// invariant is enforced through a target-type guard: the registry
/// is consulted only when the receiver is NOT a recognized built-in
/// type (String / List / Map / num / ThemeData / controllers /
/// animation targets etc.). Custom classes are never on that list,
/// so property and method semantics line up uniformly: the registry
/// extends Rune's reach to the host's own types without risking
/// source-compatibility regressions on stock Dart values.
final class MemberRegistry {
  /// Creates an empty member registry.
  MemberRegistry();

  final List<_PropertyEntry> _properties = <_PropertyEntry>[];
  final List<_MethodEntry> _methods = <_MethodEntry>[];

  /// Registers [accessor] to compute the property [name] on any value
  /// that is-a [T].
  void registerProperty<T extends Object>(
    String name,
    Object? Function(T target, RuneContext ctx) accessor,
  ) {
    _properties.add(
      _PropertyEntry(
        name: name,
        matches: (Object o) => o is T,
        invoke: (Object o, RuneContext c) => accessor(o as T, c),
      ),
    );
  }

  /// Registers [invoker] to execute the method [name] on any value
  /// that is-a [T]. [invoker] receives positional arguments in
  /// declaration order.
  void registerMethod<T extends Object>(
    String name,
    Object? Function(T target, List<Object?> positionalArgs, RuneContext ctx)
        invoker,
  ) {
    _methods.add(
      _MethodEntry(
        name: name,
        matches: (Object o) => o is T,
        invoke: (Object o, List<Object?> args, RuneContext c) =>
            invoker(o as T, args, c),
      ),
    );
  }

  /// Looks up the property [name] on [target]. Returns `(true, value)`
  /// on a registered match or `(false, null)` when no registration
  /// applies.
  ///
  /// `null` targets never match; callers should handle the null case
  /// before consulting the registry.
  (bool, Object?) resolveProperty(
    Object? target,
    String name,
    RuneContext ctx,
  ) {
    if (target == null) return (false, null);
    for (final entry in _properties) {
      if (entry.name == name && entry.matches(target)) {
        return (true, entry.invoke(target, ctx));
      }
    }
    return (false, null);
  }

  /// Invokes the method [name] on [target] with [positionalArgs].
  /// Returns `(true, result)` on a registered match or
  /// `(false, null)` when no registration applies.
  (bool, Object?) invokeMethod(
    Object? target,
    String name,
    List<Object?> positionalArgs,
    RuneContext ctx,
  ) {
    if (target == null) return (false, null);
    for (final entry in _methods) {
      if (entry.name == name && entry.matches(target)) {
        return (true, entry.invoke(target, positionalArgs, ctx));
      }
    }
    return (false, null);
  }

  /// Iterable view of every registered property name. Used by the
  /// resolver's `did-you-mean` suggestions on miss.
  Iterable<String> get propertyNames => _properties.map((e) => e.name);

  /// Iterable view of every registered method name. Used by the
  /// resolver's `did-you-mean` suggestions on miss.
  Iterable<String> get methodNames => _methods.map((e) => e.name);
}

final class _PropertyEntry {
  _PropertyEntry({
    required this.name,
    required this.matches,
    required this.invoke,
  });

  final String name;
  final bool Function(Object target) matches;
  final MemberPropertyAccessor invoke;
}

final class _MethodEntry {
  _MethodEntry({
    required this.name,
    required this.matches,
    required this.invoke,
  });

  final String name;
  final bool Function(Object target) matches;
  final MemberMethodInvoker invoke;
}
