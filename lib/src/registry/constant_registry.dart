import 'package:rune/src/core/exceptions.dart';

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
  /// Stops at the first duplicate (see [register]).
  void registerAll(String typeName, Map<String, Object?> members) {
    for (final MapEntry(:key, :value) in members.entries) {
      register(typeName, key, value);
    }
  }

  /// Returns the value registered under [typeName]/[memberName], or `null`
  /// if either half is missing.
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
  Object? require(
    String typeName,
    String memberName, {
    required String source,
  }) {
    final bucket = _members[typeName];
    if (bucket == null || !bucket.containsKey(memberName)) {
      throw ResolveException(
        source,
        'Unknown constant "$typeName.$memberName"',
      );
    }
    return bucket[memberName];
  }

  /// Total number of registered members across all types.
  int get size =>
      _members.values.fold<int>(0, (sum, bucket) => sum + bucket.length);
}
