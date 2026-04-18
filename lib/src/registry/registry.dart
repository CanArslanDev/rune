import 'package:rune/src/core/exceptions.dart';

/// A keyed, name-based registry of items of type [T].
///
/// Registrations are flat (no namespaces); duplicates raise [StateError] to
/// surface unintended double-registration at configuration time rather than
/// at runtime.
class Registry<T extends Object> {
  /// Creates an empty registry.
  Registry();

  final Map<String, T> _items = <String, T>{};

  /// Registers [item] under [name]. Throws [StateError] if [name] is taken.
  void register(String name, T item) {
    if (_items.containsKey(name)) {
      throw StateError(
        'Registry already contains an entry for "$name". '
        'Use a distinct name or a purpose-built override API.',
      );
    }
    _items[name] = item;
  }

  /// Convenience: registers every entry in [entries]. Stops at first
  /// duplicate (see [register]).
  void registerAll(Map<String, T> entries) {
    for (final MapEntry(:key, :value) in entries.entries) {
      register(key, value);
    }
  }

  /// Returns the item registered under [name], or `null` if absent.
  T? find(String name) => _items[name];

  /// Returns the item registered under [name]; throws
  /// [UnregisteredBuilderException] citing [source] if absent.
  T require(String name, {required String source}) {
    final T? item = _items[name];
    if (item == null) {
      throw UnregisteredBuilderException(source, name);
    }
    return item;
  }

  /// Whether an entry exists under [name].
  bool contains(String name) => _items.containsKey(name);

  /// Number of registered entries. Useful in tests and introspection.
  int get size => _items.length;
}
