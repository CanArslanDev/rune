import 'package:flutter/foundation.dart';

/// A [ChangeNotifier]-shaped object whose observable state is exposed
/// as a [Map] so Rune source can reach individual fields through
/// ordinary property access (`state.count`, `state.user.name`).
///
/// Rune's [PropertyResolver][] traverses map values, not Dart object
/// getters; a raw user-defined `ChangeNotifier` with typed fields is
/// opaque at the source level. Implementing this interface bridges
/// the two worlds: the notifier stays idiomatic Dart for the host app
/// (typed getters, named methods) AND exposes a per-rebuild snapshot
/// for Rune source via the `state` getter.
///
/// Typical usage:
///
/// ```dart
/// class CounterNotifier extends ChangeNotifier
///     implements RuneReactiveNotifier {
///   int _count = 0;
///   int get count => _count;
///
///   @override
///   Map<String, Object?> get state => {'count': _count};
///
///   void increment() {
///     _count += 1;
///     notifyListeners();
///   }
/// }
/// ```
///
/// The `ProviderBridge` widgets (`Consumer`, `Selector`) extract
/// `state` at each rebuild and pass the resulting map as the second
/// positional argument to the builder closure.
///
/// [PropertyResolver]: https://pub.dev/documentation/rune/latest
abstract interface class RuneReactiveNotifier implements Listenable {
  /// The current observable state, projected as a `Map` so Rune
  /// source can dot-access individual keys.
  ///
  /// Implementations should return a fresh map (or an unmodifiable
  /// view of one) per call so downstream consumers compare snapshots
  /// reliably under `==` when using `Selector`.
  Map<String, Object?> get state;
}
