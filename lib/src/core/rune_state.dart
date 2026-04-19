import 'package:flutter/foundation.dart';

/// A source-visible state container. Backs `StatefulBuilder` in Rune
/// source.
///
/// Provides:
/// - A Map-like read API ([get], [has], [entries]) that source
///   expressions reach through `PropertyResolver` /
///   `IdentifierResolver`. Writing `state.counter` in Rune source
///   resolves to `state.get('counter')`.
/// - Explicit mutation methods ([set], [setMany], [remove], [clear])
///   that schedule a widget rebuild by invoking the `onMutation`
///   callback whenever they actually change the underlying entries.
///
/// [RuneState] is distinct from `RuneScope` (Phase B): `RuneScope` is
/// transient to a closure call and holds block-body locals;
/// [RuneState] persists across rebuilds of the hosting widget and
/// triggers a rebuild when mutated.
///
/// [RuneState] is intentionally mutable by design (runtime state
/// container) and therefore not `@immutable`; `final class` is used
/// to prevent subclassing.
final class RuneState {
  /// Constructs a [RuneState] wrapping a defensive copy of `entries`
  /// with the given `onMutation` callback. The callback fires after
  /// every mutating operation that actually changed the underlying
  /// entries (see [set], [setMany], [remove], [clear]), so the
  /// hosting widget can schedule a rebuild.
  RuneState({
    required Map<String, Object?> entries,
    required VoidCallback onMutation,
  })  : _entries = Map<String, Object?>.of(entries),
        _onMutation = onMutation;

  final Map<String, Object?> _entries;
  final VoidCallback _onMutation;

  /// Reads `key`. Returns `null` when absent (ambiguous with a stored
  /// null; use [has] to distinguish).
  Object? get(String key) => _entries[key];

  /// Whether `key` is present in the state (possibly bound to `null`).
  bool has(String key) => _entries.containsKey(key);

  /// Returns the backing entries map.
  ///
  /// Exposed so `PropertyResolver` and `IdentifierResolver` can treat
  /// [RuneState] as a Map-like target. Direct mutation of the
  /// returned map bypasses the `onMutation` callback and therefore
  /// will not trigger a rebuild; always use [set], [setMany], [remove],
  /// or [clear] from Rune source.
  Map<String, Object?> get entries => _entries;

  /// Sets `key` to `value` and fires the `onMutation` callback.
  ///
  /// Always fires, even when the new value equals the old one; Rune
  /// source callers who want conditional rebuilds check before
  /// calling.
  void set(String key, Object? value) {
    _entries[key] = value;
    _onMutation();
  }

  /// Merges `additions` into the state and fires the `onMutation`
  /// callback once (regardless of how many keys were merged).
  void setMany(Map<String, Object?> additions) {
    _entries.addAll(additions);
    _onMutation();
  }

  /// Removes `key`. Returns `true` when the key was present (in which
  /// case the `onMutation` callback fires); returns `false` when the
  /// key was absent (in which case the callback does NOT fire to
  /// avoid spurious rebuilds).
  bool remove(String key) {
    final hadKey = _entries.containsKey(key);
    if (!hadKey) return false;
    _entries.remove(key);
    _onMutation();
    return true;
  }

  /// Clears all entries. Fires the `onMutation` callback only when
  /// the state was non-empty; a clear on an already-empty state is a
  /// no-op to avoid spurious rebuilds.
  void clear() {
    if (_entries.isEmpty) return;
    _entries.clear();
    _onMutation();
  }
}
