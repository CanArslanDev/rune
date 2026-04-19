import 'package:flutter/foundation.dart';

/// A named, reusable source fragment.
///
/// Declared in Rune source via
/// `RuneComponent(name: 'MyButton', params: ['label', 'onTap'],
/// body: (label, onTap) => ElevatedButton(onPressed: onTap,
/// child: Text(label)))`. Later invocations `MyButton(label: 'Go',
/// onTap: ...)` dispatch through the `ComponentRegistry` ahead of the
/// widget and value registries.
///
/// Components are source-scoped: each `RuneView.source` gets a fresh
/// registry. Components are not shared across views and not persisted
/// across rebuilds - they are re-declared on every resolve of the
/// source expression.
///
/// Components differ from `RuneClosure`s in three ways:
///   * Invocation uses named arguments at the call site; the component
///     reorders them into positional args against [parameterNames]
///     before handing them to [body].
///   * They carry a display [name] for error messages and registry
///     lookup.
///   * They are looked up by name in a dedicated registry, whereas
///     closures are bound to identifiers in scope.
///
/// The [body] signature is intentionally framework-agnostic
/// (`Object? Function(List<Object?>)`): production use wraps a
/// `RuneClosure` call, but tests can supply any plain Dart callable.
/// This keeps the `core/` layer free of resolver imports.
@immutable
final class RuneComponent {
  /// Constructs a component.
  ///
  /// [name] is the display name used for registry lookup and error
  /// messages. [parameterNames] are the declared parameter names in
  /// order; the invocation resolver extracts positional arguments from
  /// the call's named argument map against this list. [body] is the
  /// closure-like callable invoked with those positional values.
  const RuneComponent({
    required this.name,
    required this.parameterNames,
    required this.body,
  });

  /// The component's display name. Used for registry lookup and error
  /// messages.
  final String name;

  /// Declared parameter names in order.
  ///
  /// At invocation the resolver requires every name to be supplied as
  /// a named argument; extras and missing names both raise
  /// `ResolveException`.
  final List<String> parameterNames;

  /// The component's body.
  ///
  /// Receives the call's arguments as positional values in the order
  /// declared by [parameterNames]. The returned value is whatever the
  /// component produces: a `Widget` for widget-shaped components, or
  /// any other value.
  final Object? Function(List<Object?>) body;

  @override
  String toString() =>
      'RuneComponent($name, params: [${parameterNames.join(', ')}])';
}
