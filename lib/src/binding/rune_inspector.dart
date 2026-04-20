import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show immutable;

/// Opaque handle returned from [RuneInspector.registerView].
///
/// Callers pass it back to [RuneInspector.unregisterView] during
/// teardown. Handles are not reused after removal; comparing two
/// handles with `==` always returns `false` unless they refer to the
/// same registration.
@immutable
final class RuneInspectorHandle {
  const RuneInspectorHandle._(this.id);

  /// Stable numeric identifier. Matches the `id` field each payload
  /// entry carries, so callers can correlate a handle with its row
  /// in [RuneInspector.collectInspectionPayload].
  final int id;

  @override
  bool operator ==(Object other) =>
      other is RuneInspectorHandle && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RuneInspectorHandle($id)';
}

/// Signature of a snapshot producer. Invoked on demand every time
/// the DevTools extension (or a programmatic caller) requests a
/// payload. Must return a freshly allocated, JSON-serialisable map.
///
/// Throwing from a producer is permitted: [RuneInspector] catches
/// the error and surfaces it as a `snapshotError` field on the
/// affected view's payload entry so a single misbehaving view does
/// not crash the whole inspection call.
typedef RuneInspectionSnapshotBuilder = Map<String, Object?> Function();

/// Process-wide registry of live `RuneView` instances for
/// introspection.
///
/// The main usecase is the companion `rune_devtools_extension` package:
/// it calls the `ext.rune.inspect` VM service extension, which in turn
/// asks this inspector for a snapshot of every live view. Because the
/// VM service extension is registered lazily the first time a view
/// mounts and stays up for the process lifetime, release builds pay
/// zero cost when no view is ever inspected (`dart:developer.register
/// Extension` is a no-op in release mode).
///
/// A singleton is the right shape here: there is exactly one VM
/// service per isolate, and the companion extension identifies views
/// by their registration order rather than any host-side identity.
/// Tests that need isolation can call [resetForTesting] to clear the
/// registry between cases.
final class RuneInspector {
  RuneInspector._();

  /// The process-wide inspector.
  static final RuneInspector instance = RuneInspector._();

  final Map<int, RuneInspectionSnapshotBuilder> _builders =
      <int, RuneInspectionSnapshotBuilder>{};
  int _nextId = 0;
  bool _extensionRegistered = false;

  /// Number of currently registered views. Exposed for tests and
  /// internal diagnostics; not part of the payload.
  int get liveViewCount => _builders.length;

  /// Registers [snapshotBuilder] and returns a handle the caller must
  /// pass back to [unregisterView] on teardown.
  ///
  /// Lazy-registers the `ext.rune.inspect` service extension the
  /// first time a view joins the registry; subsequent registrations
  /// are a cheap map insert. In release mode the service extension
  /// registration is a no-op (the underlying `dart:developer`
  /// primitive is compiled out).
  RuneInspectorHandle registerView(
    RuneInspectionSnapshotBuilder snapshotBuilder,
  ) {
    final id = _nextId++;
    _builders[id] = snapshotBuilder;
    _ensureServiceExtensionRegistered();
    return RuneInspectorHandle._(id);
  }

  /// Removes the registration created with [registerView]. Tolerant
  /// of handles that have already been removed; calling twice is a
  /// no-op.
  void unregisterView(RuneInspectorHandle handle) {
    _builders.remove(handle.id);
  }

  /// Builds the JSON-safe inspection payload returned by the service
  /// extension (and usable from tests).
  ///
  /// Shape:
  ///
  /// ```json
  /// {
  ///   "views": [
  ///     { "id": 0, "source": "...", "data": {...}, "lastError": null },
  ///     { "id": 1, "snapshotError": "StateError: ..." }
  ///   ]
  /// }
  /// ```
  ///
  /// Each entry contains the fields the registered builder chose to
  /// expose, plus an injected numeric `id` and (on failure) a
  /// `snapshotError` string. Values are walked recursively and any
  /// leaf that is not JSON-native (not null / bool / num / String /
  /// Map / List / Iterable) is coerced to its `toString()` form so
  /// the whole payload round-trips through `jsonEncode` cleanly.
  Map<String, Object?> collectInspectionPayload() {
    final views = <Map<String, Object?>>[];
    for (final entry in _builders.entries) {
      final wire = <String, Object?>{'id': entry.key};
      try {
        entry.value().forEach((key, value) {
          wire[key] = _serialiseForWire(value);
        });
      } on Object catch (e) {
        wire['snapshotError'] = e.toString();
      }
      views.add(wire);
    }
    return <String, Object?>{'views': views};
  }

  /// Clears every registration. Intended for tests; calling at runtime
  /// silently invalidates any outstanding handles.
  void resetForTesting() {
    _builders.clear();
    _nextId = 0;
  }

  void _ensureServiceExtensionRegistered() {
    if (_extensionRegistered) return;
    _extensionRegistered = true;
    developer.registerExtension(
      'ext.rune.inspect',
      (String method, Map<String, String> parameters) async {
        final payload = collectInspectionPayload();
        return developer.ServiceExtensionResponse.result(jsonEncode(payload));
      },
    );
  }
}

/// Walks [value] recursively and returns a JSON-native copy. Map
/// entries are wrapped with string keys (non-String keys stringify);
/// non-native leaves fall back to `toString()`. Pre-allocated
/// collections are copied defensively so the wire payload cannot
/// alias host-owned state.
Object? _serialiseForWire(Object? value) {
  if (value == null ||
      value is bool ||
      value is num ||
      value is String) {
    return value;
  }
  if (value is Map) {
    final result = <String, Object?>{};
    value.forEach((k, v) {
      result[k.toString()] = _serialiseForWire(v);
    });
    return result;
  }
  if (value is Iterable) {
    return value.map(_serialiseForWire).toList(growable: false);
  }
  return value.toString();
}
