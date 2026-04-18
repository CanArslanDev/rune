import 'package:flutter/foundation.dart';
import 'package:rune/src/core/exceptions.dart';

/// A type-safe wrapper around a builder invocation's resolved positional
/// and named arguments.
///
/// All values have already been resolved — builders receive Dart values
/// (ints, Widgets, `EdgeInsets`, etc.), never AST nodes.
@immutable
final class ResolvedArguments {
  /// Constructs a new set of resolved arguments. Both collections default
  /// to empty const collections.
  const ResolvedArguments({
    this.positional = const <Object?>[],
    this.named = const <String, Object?>{},
  });

  /// The empty singleton — useful for builders with no arguments.
  static const ResolvedArguments empty = ResolvedArguments();

  /// Positional arguments in source order.
  final List<Object?> positional;

  /// Named arguments keyed by their label.
  final Map<String, Object?> named;

  /// Reads the named argument [name] as type [T]. Returns `null` when
  /// absent or the stored value is itself null.
  T? get<T>(String name) => named[name] as T?;

  /// Reads the named argument [name] as type [T], returning [fallback]
  /// when absent or null.
  T getOr<T extends Object>(String name, T fallback) {
    final Object? value = named[name];
    return (value ?? fallback) as T;
  }

  /// Reads a required named argument. Throws [ArgumentException] citing
  /// [source] when missing or null.
  T require<T extends Object>(String name, {required String source}) {
    final Object? value = named[name];
    if (value == null) {
      throw ArgumentException(
        source,
        'Missing required argument "$name"',
      );
    }
    return value as T;
  }

  /// Reads the [index]-th positional argument as type [T], or `null` when
  /// the index is out of range or the value is null.
  T? positionalAt<T>(int index) {
    if (index < 0 || index >= positional.length) return null;
    return positional[index] as T?;
  }

  /// Reads a required positional argument. Throws [ArgumentException]
  /// citing [source] when missing or null.
  T requirePositional<T extends Object>(
    int index, {
    required String source,
  }) {
    if (index < 0 || index >= positional.length) {
      throw ArgumentException(
        source,
        'Missing positional argument at index $index',
      );
    }
    final Object? value = positional[index];
    if (value == null) {
      throw ArgumentException(
        source,
        'Positional argument at index $index is null',
      );
    }
    return value as T;
  }
}
