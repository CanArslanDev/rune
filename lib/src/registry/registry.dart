import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/source_span.dart';

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
        '$runtimeType already contains an entry for "$name". '
        'Use a distinct name or a purpose-built override API.',
      );
    }
    _items[name] = item;
  }

  /// Convenience: registers every entry in [entries]. Stops at first
  /// duplicate (see [register]). Entries processed before the duplicate
  /// remain registered — `registerAll` is not transactional.
  void registerAll(Map<String, T> entries) {
    for (final MapEntry(:key, :value) in entries.entries) {
      register(key, value);
    }
  }

  /// Returns the item registered under [name], or `null` if absent.
  T? find(String name) => _items[name];

  /// Returns the item registered under [name]; throws
  /// [UnregisteredBuilderException] citing [source] if absent.
  ///
  /// [location] is an optional [SourceSpan] pointing into the Rune source
  /// where the offending reference sits. Resolver callers with an AST node
  /// in hand thread one through; non-resolver callers may omit it.
  ///
  /// Note: this registry is used exclusively by builder lookups in Phase 1,
  /// so the exception's `typeName` maps naturally to the registered key. A
  /// future task may introduce a generic "registry miss" exception when
  /// non-builder registries are added.
  T require(String name, {required String source, SourceSpan? location}) {
    final item = _items[name];
    if (item == null) {
      throw UnregisteredBuilderException(source, name, location: location);
    }
    return item;
  }

  /// Whether an entry exists under [name].
  bool contains(String name) => _items.containsKey(name);

  /// Number of registered entries. Useful in tests and introspection.
  int get size => _items.length;

  /// Iterable view of every registered entry's name.
  ///
  /// Used by resolver throw sites to compute Levenshtein-based
  /// "did you mean ...?" suggestions without exposing the backing map.
  /// Iteration order follows insertion order of the underlying map.
  Iterable<String> get names => _items.keys;
}
