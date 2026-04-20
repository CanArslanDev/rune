import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/source_span.dart';

/// A two-level registry of named static constants keyed by
/// `typeName.memberName` (e.g. `Colors.red`, `MainAxisAlignment.center`).
///
/// Phase 2a seeds this with the default `Colors`, enum values, and a
/// handful of common constants via `registerPhase2aConstants`.
final class ConstantRegistry {
  /// Constructs an empty [ConstantRegistry].
  ConstantRegistry();

  final Map<String, Map<String, Object?>> _members =
      <String, Map<String, Object?>>{};

  /// Registers a single member under [typeName]/[memberName]. Throws
  /// [StateError] on duplicate.
  void register(String typeName, String memberName, Object? value) {
    final bucket = _members.putIfAbsent(
      typeName,
      () => <String, Object?>{},
    );
    if (bucket.containsKey(memberName)) {
      throw StateError(
        '$runtimeType already contains "$typeName.$memberName". '
        'Use a distinct name or remove the prior registration.',
      );
    }
    bucket[memberName] = value;
  }

  /// Convenience: registers every entry in [members] under [typeName].
  ///
  /// Not transactional: entries inserted before a duplicate key is hit are
  /// retained, and the throw from [register] aborts the rest. Callers that
  /// need rollback-on-failure should pre-validate with [contains] or use
  /// the single-entry [register] in a try/catch.
  void registerAll(String typeName, Map<String, Object?> members) {
    for (final MapEntry(:key, :value) in members.entries) {
      register(typeName, key, value);
    }
  }

  /// Returns the value registered under [typeName]/[memberName], or `null`
  /// if either half is missing.
  ///
  /// A `null` return is ambiguous when nullable constants are in play: it
  /// may signal absence **or** a legitimately-registered `null` value. Use
  /// [contains] to distinguish the two cases.
  Object? resolve(String typeName, String memberName) {
    return _members[typeName]?[memberName];
  }

  /// Whether a value — possibly null — is registered under
  /// [typeName]/[memberName].
  bool contains(String typeName, String memberName) {
    final bucket = _members[typeName];
    return bucket != null && bucket.containsKey(memberName);
  }

  /// Returns the value registered under [typeName]/[memberName], or throws
  /// [ResolveException] citing [source] if the pair is unknown.
  ///
  /// [location] is an optional [SourceSpan] pointing into the Rune source
  /// where the offending reference sits. Resolver callers thread one
  /// through; non-resolver callers may omit it.
  Object? require(
    String typeName,
    String memberName, {
    required String source,
    SourceSpan? location,
  }) {
    final bucket = _members[typeName];
    if (bucket == null || !bucket.containsKey(memberName)) {
      throw ResolveException(
        source,
        'Unknown constant "$typeName.$memberName"',
        location: location,
      );
    }
    return bucket[memberName];
  }

  /// Total number of registered members across all types.
  int get size =>
      _members.values.fold<int>(0, (sum, bucket) => sum + bucket.length);

  /// Iterable view of every registered type name (outer keys). Used by
  /// resolver throw sites to compute suggestions on an unknown prefix
  /// (`Colros.red` → suggest `Colors`).
  Iterable<String> get typeNames => _members.keys;

  /// Iterable view of the member names registered under [typeName].
  /// Returns an empty iterable when [typeName] is unknown. Used when
  /// the type is right but the member is misspelled
  /// (`Colors.redd` → suggest `red`).
  Iterable<String> memberNamesOf(String typeName) {
    final bucket = _members[typeName];
    if (bucket == null) return const <String>[];
    return bucket.keys;
  }
}
