import 'package:flutter/foundation.dart';

/// An immutable bag of runtime data that can be referenced from a Rune
/// source (e.g. `Text(userName)` → looked up via `DataContext.get('userName')`).
///
/// Phase 1 supports only flat string keys. Dot-notation (`user.name`) and
/// nested object traversal are introduced in Phase 3.
@immutable
final class DataContext {
  /// Constructs a [DataContext] wrapping the given [data] map.
  const DataContext(this._data);

  /// The empty, const singleton.
  static const DataContext empty = DataContext(<String, Object?>{});

  final Map<String, Object?> _data;

  /// Returns the value stored at [key], or `null` if absent.
  Object? get(String key) => _data[key];

  /// Whether a value — possibly null — exists for [key].
  bool has(String key) => _data.containsKey(key);

  /// Returns a new [DataContext] with [additions] merged on top of this one.
  /// Useful when builders introduce scoped variables (e.g. loop iteration).
  DataContext extend(Map<String, Object?> additions) {
    return DataContext(<String, Object?>{..._data, ...additions});
  }
}
