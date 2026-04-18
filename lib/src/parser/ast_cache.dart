import 'package:analyzer/dart/ast/ast.dart';

/// An LRU cache mapping Rune source strings to their parsed [Expression]
/// ASTs.
///
/// Leverages Dart's default `Map` (a `LinkedHashMap`) insertion-order
/// guarantee to track recency: each access re-inserts the entry at the
/// tail. Eviction drops the head entry on overflow.
final class AstCache {
  /// Constructs an [AstCache] with the given [maxSize] (default 64).
  /// Asserts [maxSize] is positive.
  AstCache({this.maxSize = 64}) : assert(maxSize > 0, 'maxSize must be > 0');

  /// Maximum number of entries retained. The least-recently-used entry is
  /// evicted when inserting past this limit.
  final int maxSize;

  final Map<String, Expression> _entries = <String, Expression>{};

  /// Returns the cached expression for [source], or `null` on miss.
  /// Touches the entry so it becomes the most-recently-used.
  Expression? get(String source) {
    final Expression? expr = _entries.remove(source);
    if (expr != null) {
      _entries[source] = expr;
    }
    return expr;
  }

  /// Inserts or updates the cache. Evicts the least-recently-used entry
  /// when [maxSize] would be exceeded.
  void put(String source, Expression expression) {
    _entries.remove(source);
    if (_entries.length >= maxSize) {
      _entries.remove(_entries.keys.first);
    }
    _entries[source] = expression;
  }

  /// Removes every cached entry.
  void clear() => _entries.clear();

  /// Current number of cached entries.
  int get size => _entries.length;
}
