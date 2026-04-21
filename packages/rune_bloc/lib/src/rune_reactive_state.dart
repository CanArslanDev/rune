/// A mixin / interface for state classes (or Cubit states) that
/// expose their fields as a JSON-native map for Rune source to
/// dot-access.
///
/// BLoC state is idiomatically a typed Dart class (or freezed
/// union). Rune source cannot reach typed Dart getters without an
/// explicit registration, so this interface gives each state a
/// `toRuneMap()` hook that Rune's source resolver consumes at
/// `BlocBuilder.builder(ctx, state, child)` dispatch time.
///
/// Typical usage:
///
/// ```dart
/// class CounterState implements RuneReactiveState {
///   const CounterState({required this.count});
///   final int count;
///
///   @override
///   Map<String, Object?> toRuneMap() => {'count': count};
/// }
/// ```
///
/// The `BlocBridge` widgets fall back to an empty map when the
/// state does not implement this interface, so a plain `int`
/// cubit (`Cubit<int>`) still renders; you just lose dot-access.
///
/// Single-method shape is intentional: the interface is a
/// BLoC-side dual of `RuneReactiveNotifier` from rune_provider
/// (same role, different state-management framework).
// ignore: one_member_abstracts
abstract interface class RuneReactiveState {
  /// Returns a JSON-native projection of the state. Called once
  /// per rebuild inside `BlocBuilder` / `BlocListener`.
  Map<String, Object?> toRuneMap();
}
