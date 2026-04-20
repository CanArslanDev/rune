import 'package:rune/src/core/rune_component.dart';

/// Per-`RuneView` registry of named Rune components.
///
/// Components are declared in source via `RuneComponent(...)` and
/// invoked by name (e.g. `MyButton(label: 'Go')`). Each `RuneView`
/// render allocates a fresh `ComponentRegistry`; components are NOT
/// global and do NOT leak between views.
///
/// Unlike `WidgetRegistry` / `ValueRegistry`, `ComponentRegistry` is
/// keyed by the component value itself: callers pass a [RuneComponent]
/// whose `name` becomes the registry key. This keeps the source-level
/// definition API symmetric ("one `RuneComponent(...)` expression, one
/// registration").
final class ComponentRegistry {
  /// Creates an empty registry.
  ComponentRegistry();

  final Map<String, RuneComponent> _components = <String, RuneComponent>{};

  /// Registers [component] under its declared name.
  ///
  /// Throws [StateError] if a component with the same name is already
  /// registered. Source-level redeclaration within a single resolve of
  /// a single source string is a bug; each component is declared
  /// exactly once per render.
  void register(RuneComponent component) {
    if (_components.containsKey(component.name)) {
      throw StateError(
        'Component "${component.name}" is already registered',
      );
    }
    _components[component.name] = component;
  }

  /// Returns the component registered under [name], or `null` when
  /// absent.
  RuneComponent? find(String name) => _components[name];

  /// Whether a component is registered under [name].
  bool contains(String name) => _components.containsKey(name);

  /// Number of registered components.
  int get size => _components.length;

  /// Iterable view of every registered component's name. Used by
  /// resolver throw sites to compute Levenshtein-based suggestions.
  Iterable<String> get names => _components.keys;
}
