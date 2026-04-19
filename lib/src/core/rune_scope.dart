import 'package:rune/src/core/exceptions.dart';

/// A mutable local scope threaded through block-body closure execution
/// and nested statements.
///
/// Distinct from `RuneDataContext`: the latter is immutable and holds
/// data the host app supplies; [RuneScope] is mutable and holds local
/// variables declared inside source-level closure bodies (e.g.
/// `final doubled = counter * 2;` inside a `(i) { ... }` closure).
///
/// Scopes nest: a child scope wraps its parent and looks up unknown
/// names by walking outward. [assign] writes to the scope that
/// declared the name (not always the innermost), so nested blocks
/// can re-bind an outer variable without shadowing it.
///
/// [RuneScope] is mutable by design and therefore not `@immutable`;
/// this is one of the very few mutable value types in Rune's runtime.
final class RuneScope {
  /// Constructs a top-level scope with no parent.
  RuneScope()
      : _parent = null,
        _entries = <String, Object?>{};

  /// Constructs a child scope rooted at [parent]. [parent] is not
  /// modified by child creation; declarations in the child are
  /// independent and shadow parent names of the same ilk. [assign]
  /// may still reach into [parent] when the target name is declared
  /// there.
  RuneScope.child(RuneScope parent)
      : _parent = parent,
        _entries = <String, Object?>{};

  final RuneScope? _parent;
  final Map<String, Object?> _entries;

  /// Declares [name] in THIS scope with the given initial [value].
  ///
  /// Throws [StateError] if [name] is already declared in this scope
  /// (re-declaration is a programming error; Dart forbids it too).
  /// Shadowing a name declared in an outer scope IS allowed.
  void declare(String name, Object? value) {
    if (_entries.containsKey(name)) {
      throw StateError(
        'Cannot re-declare local variable "$name" in the same scope',
      );
    }
    _entries[name] = value;
  }

  /// Reassigns [name] to [value].
  ///
  /// Walks outward through parents until the declaring scope is found
  /// and writes there. Throws [BindingException] when [name] is not
  /// declared in any scope (Rune's equivalent of Dart's "undefined
  /// name" error).
  void assign(String name, Object? value) {
    if (_entries.containsKey(name)) {
      _entries[name] = value;
      return;
    }
    final parent = _parent;
    if (parent != null) {
      parent.assign(name, value);
      return;
    }
    throw BindingException(
      name,
      'Cannot assign to undeclared local variable "$name"',
    );
  }

  /// Looks up [name] starting from this scope and walking outward.
  ///
  /// Returns `null` if absent in every ancestor. Use [has] to
  /// distinguish absent from an explicitly-null value.
  Object? lookup(String name) {
    if (_entries.containsKey(name)) return _entries[name];
    return _parent?.lookup(name);
  }

  /// Whether [name] is declared in this scope or any ancestor.
  ///
  /// Returns `true` even when the declared value is `null`.
  bool has(String name) {
    if (_entries.containsKey(name)) return true;
    return _parent?.has(name) ?? false;
  }
}
