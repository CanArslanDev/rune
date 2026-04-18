import 'package:flutter/foundation.dart';

/// An immutable bag of runtime data that can be referenced from a Rune
/// source (e.g. `Text(userName)` → looked up via `DataContext.get('userName')`).
///
/// The constructor wraps the incoming map with `Map.unmodifiable` so callers
/// cannot mutate the internal state after construction.
///
/// Phase 1 supports only flat string keys. Dot-notation (`user.name`) and
/// nested object traversal are introduced in Phase 3.
@immutable
final class DataContext {
  /// Constructs a [DataContext] wrapping a defensive copy of [data].
  ///
  /// The stored map is `Map.unmodifiable`, so even if the caller retains
  /// a reference to [data] and mutates it, the [DataContext] remains
  /// consistent.
  DataContext(Map<String, Object?> data)
      : _data = Map<String, Object?>.unmodifiable(data);

  /// The empty singleton. Initialized lazily on first access.
  static final DataContext empty = DataContext(const <String, Object?>{});

  final Map<String, Object?> _data;

  /// Returns the value stored at [key], or `null` if the key is absent.
  ///
  /// A `null` return is ambiguous by itself — it signals both "the key was
  /// not in the map" and "the key was present with a null value". Use [has]
  /// to distinguish the two cases.
  Object? get(String key) => _data[key];

  /// Whether a value — possibly `null` — exists for [key].
  bool has(String key) => _data.containsKey(key);

  /// Returns a new [DataContext] with [additions] merged on top of this one.
  ///
  /// Non-mutating: the receiver is unchanged. Useful when builders introduce
  /// scoped variables (e.g. list-iteration bindings).
  DataContext extend(Map<String, Object?> additions) {
    return DataContext(<String, Object?>{..._data, ...additions});
  }
}
