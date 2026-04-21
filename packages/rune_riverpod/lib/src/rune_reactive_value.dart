/// A value class that exposes its fields as a JSON-native map for
/// Rune source to dot-access.
///
/// Riverpod providers commonly emit typed immutable state objects
/// (freezed unions, @immutable data classes, etc.). Rune source
/// cannot reach typed Dart getters without an explicit
/// registration, so Rune consumers of Riverpod-managed state
/// either:
///
/// - Implement this interface on the emitted type so
///   `RiverpodConsumer`'s `builder(ctx, value, child)` automatically
///   receives `value.toRuneMap()` instead of the raw typed value;
/// - OR register property/method accessors through
///   `config.members.registerProperty<MyType>(...)` (v1.17.0+) and
///   get the raw typed value through the builder.
///
/// ```dart
/// class CounterState implements RuneReactiveValue {
///   const CounterState(this.count);
///   final int count;
///
///   @override
///   Map<String, Object?> toRuneMap() => {'count': count};
/// }
/// ```
///
/// Single-method shape is intentional: the interface is a
/// Riverpod-side dual of `RuneReactiveNotifier` (`rune_provider`)
/// and `RuneReactiveState` (`rune_bloc`). Same role, different
/// state-management framework.
// ignore: one_member_abstracts
abstract interface class RuneReactiveValue {
  /// Returns a JSON-native projection of the value. Called once
  /// per rebuild inside `RiverpodConsumer`.
  Map<String, Object?> toRuneMap();
}
