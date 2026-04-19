/// A closed whitelist of built-in property accesses and method invocations
/// on ordinary runtime values — `String`, `List`, `Map`, and `num`.
///
/// Rune never invokes arbitrary methods. Every supported `(target type,
/// member name)` pair is enumerated here. Unknown pairs surface as a
/// [ResolveException] pointing at the offending source. This preserves
/// the store-review-compliance posture (no reflection, no dynamic
/// dispatch, no `dart:mirrors`) while still letting consumers write the
/// idiomatic expressions they expect from Dart source.
///
/// Two entry points:
///
/// - [resolveBuiltinProperty] — called from `PropertyResolver` between
///   the Map-key fast-path and the extension registry fallback. Returns
///   `(true, value)` when the pair is on the whitelist, `(false, null)`
///   otherwise. A `false` first element instructs the caller to fall
///   through, preserving bridge-registered custom extensions like
///   `.w` / `.h` / `.px`.
/// - [invokeBuiltinMethod] — called from `InvocationResolver` for runtime
///   method dispatch. Throws [ResolveException] on arity mismatch, type
///   mismatch, named arguments (runtime methods are positional-only in
///   Rune source), or unknown `(type, method)` pair.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/rune_state.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/resolver/rune_closure.dart';

/// Looks up [propertyName] on [target] in the built-in property whitelist.
///
/// Returns `(true, value)` when the pair matches — the caller should
/// return `value`. Returns `(false, null)` when the pair is not on the
/// whitelist — the caller should fall through to its next dispatch step
/// (typically the extension registry).
///
/// Whitelist (by target type):
///
/// - `String`: `length`, `isEmpty`, `isNotEmpty`
/// - `List`: `length`, `isEmpty`, `isNotEmpty`, `first`, `last`
/// - `Map`: `length`, `isEmpty`, `isNotEmpty`, `keys` (materialised to a
///   `List`), `values` (materialised to a `List`)
///
/// `.first` and `.last` on an empty list propagate Dart's own
/// [StateError] unchanged — the diagnostic is identical to what a
/// consumer would see in regular Dart code.
(bool, Object?) resolveBuiltinProperty(Object? target, String propertyName) {
  if (target is String) {
    return switch (propertyName) {
      'length' => (true, target.length),
      'isEmpty' => (true, target.isEmpty),
      'isNotEmpty' => (true, target.isNotEmpty),
      _ => (false, null),
    };
  }
  if (target is List<Object?>) {
    return switch (propertyName) {
      'length' => (true, target.length),
      'isEmpty' => (true, target.isEmpty),
      'isNotEmpty' => (true, target.isNotEmpty),
      'first' => (true, target.first),
      'last' => (true, target.last),
      _ => (false, null),
    };
  }
  if (target is Map<Object?, Object?>) {
    return switch (propertyName) {
      'length' => (true, target.length),
      'isEmpty' => (true, target.isEmpty),
      'isNotEmpty' => (true, target.isNotEmpty),
      'keys' => (true, target.keys.toList()),
      'values' => (true, target.values.toList()),
      _ => (false, null),
    };
  }
  return (false, null);
}

/// Invokes a whitelisted built-in method on [target].
///
/// Whitelist (by target type):
///
/// - Any: `toString` (0 args) — returns `value?.toString() ?? 'null'`.
/// - `String`: `toUpperCase`, `toLowerCase`, `trim` (0 args); `contains`,
///   `startsWith`, `endsWith`, `split` (1 `String` arg); `substring`
///   (1 or 2 `int` args); `replaceAll` (2 `String` args).
/// - `List`: `contains`, `indexOf` (1 arg of any type); `join` (0 or 1
///   `String` arg, default separator `''`); `map`, `where`, `any`,
///   `every`, `firstWhere`, `forEach` (1 closure arg of arity 1);
///   `fold` (initial value + closure of arity 2); `reduce` (1 closure
///   arg of arity 2). `map`, `where` return materialised `List`s
///   (lazy `Iterable`s are not exposed). `any`, `every`, and the
///   closures passed to `where` / `firstWhere` must return `bool`;
///   a non-bool return raises [ResolveException]. `firstWhere`
///   propagates Dart's own [StateError] on no-match; `reduce` does
///   the same on an empty list. No-`orElse` variant of `firstWhere`
///   only; the named-arg form is deferred.
/// - `Map`: `containsKey`, `containsValue` (1 arg of any type).
/// - `num`: `abs`, `round`, `floor`, `ceil`, `toInt`, `toDouble` (0 args).
///
/// Any other `(type, method)` pair raises [ResolveException].
///
/// Named arguments are never accepted on runtime methods: every
/// whitelisted method is positional-only in Dart and runtime dispatch
/// has no way to validate arbitrary names. A non-empty [namedArgs]
/// raises [ResolveException].
///
/// [sourceNode] and [ctx] are consumed only for error reporting — every
/// thrown [ResolveException] carries a [SourceSpan] rebased via
/// [SourceSpan.fromAstOffset].
Object? invokeBuiltinMethod({
  required Object? target,
  required String methodName,
  required List<Object?> positionalArgs,
  required Map<String, Object?> namedArgs,
  required AstNode sourceNode,
  required RuneContext ctx,
}) {
  final source = sourceNode.toSource();
  SourceSpan locationOf() => SourceSpan.fromAstOffset(
        ctx.source,
        sourceNode.offset,
        sourceNode.length,
      );

  if (namedArgs.isNotEmpty) {
    throw ResolveException(
      source,
      'Runtime methods do not accept named arguments; '
      'got ${namedArgs.keys.join(", ")} on $methodName',
      location: locationOf(),
    );
  }

  // `toString` applies to any target, including null.
  if (methodName == 'toString') {
    if (positionalArgs.isNotEmpty) {
      throw ResolveException(
        source,
        'toString expects 0 positional args, got ${positionalArgs.length}',
        location: locationOf(),
      );
    }
    return target?.toString() ?? 'null';
  }

  if (target is String) {
    return _invokeStringMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }
  if (target is List<Object?>) {
    return _invokeListMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }
  if (target is Map<Object?, Object?>) {
    return _invokeMapMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }
  if (target is num) {
    return _invokeNumMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }
  if (target is RuneState) {
    return _invokeRuneStateMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }

  throw ResolveException(
    source,
    'No built-in method "$methodName" on ${target.runtimeType}',
    location: locationOf(),
  );
}

Object? _invokeRuneStateMethod({
  required RuneState target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  void requireArity(int expected) {
    if (positionalArgs.length != expected) {
      throw ResolveException(
        source,
        '$methodName expects $expected positional '
        'arg${expected == 1 ? "" : "s"}, got ${positionalArgs.length}',
        location: locationOf(),
      );
    }
  }

  String requireStringKey(int index) {
    final v = positionalArgs[index];
    if (v is! String) {
      throw ResolveException(
        source,
        '$methodName expects a String key at position $index, '
        'got ${v.runtimeType}',
        location: locationOf(),
      );
    }
    return v;
  }

  switch (methodName) {
    case 'get':
      requireArity(1);
      return target.get(requireStringKey(0));
    case 'has':
      requireArity(1);
      return target.has(requireStringKey(0));
    case 'set':
      requireArity(2);
      target.set(requireStringKey(0), positionalArgs[1]);
      return null;
    case 'setMany':
      requireArity(1);
      final additions = positionalArgs[0];
      if (additions is! Map<Object?, Object?>) {
        throw ResolveException(
          source,
          'setMany expects a Map<String, Object?> at position 0, '
          'got ${additions.runtimeType}',
          location: locationOf(),
        );
      }
      target.setMany(
        additions.map<String, Object?>(
          (k, v) => MapEntry(k.toString(), v),
        ),
      );
      return null;
    case 'remove':
      requireArity(1);
      return target.remove(requireStringKey(0));
    case 'clear':
      requireArity(0);
      target.clear();
      return null;
  }

  throw ResolveException(
    source,
    'No built-in method "$methodName" on RuneState',
    location: locationOf(),
  );
}

Object? _invokeStringMethod({
  required String target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  void requireArity(int expected) {
    if (positionalArgs.length != expected) {
      throw ResolveException(
        source,
        '$methodName expects $expected positional '
        'arg${expected == 1 ? "" : "s"}, got ${positionalArgs.length}',
        location: locationOf(),
      );
    }
  }

  T requireArg<T>(int index) {
    final v = positionalArgs[index];
    if (v is! T) {
      throw ResolveException(
        source,
        '$methodName expects $T at position $index, got ${v.runtimeType}',
        location: locationOf(),
      );
    }
    return v;
  }

  switch (methodName) {
    case 'toUpperCase':
      requireArity(0);
      return target.toUpperCase();
    case 'toLowerCase':
      requireArity(0);
      return target.toLowerCase();
    case 'trim':
      requireArity(0);
      return target.trim();
    case 'contains':
      requireArity(1);
      return target.contains(requireArg<String>(0));
    case 'startsWith':
      requireArity(1);
      return target.startsWith(requireArg<String>(0));
    case 'endsWith':
      requireArity(1);
      return target.endsWith(requireArg<String>(0));
    case 'split':
      requireArity(1);
      return target.split(requireArg<String>(0));
    case 'substring':
      if (positionalArgs.length != 1 && positionalArgs.length != 2) {
        throw ResolveException(
          source,
          'substring expects 1 or 2 positional args, '
          'got ${positionalArgs.length}',
          location: locationOf(),
        );
      }
      final start = requireArg<int>(0);
      if (positionalArgs.length == 1) {
        return target.substring(start);
      }
      final end = requireArg<int>(1);
      return target.substring(start, end);
    case 'replaceAll':
      requireArity(2);
      return target.replaceAll(requireArg<String>(0), requireArg<String>(1));
  }

  throw ResolveException(
    source,
    'No built-in method "$methodName" on String',
    location: locationOf(),
  );
}

Object? _invokeListMethod({
  required List<Object?> target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  switch (methodName) {
    case 'contains':
      if (positionalArgs.length != 1) {
        throw ResolveException(
          source,
          'contains expects 1 positional arg, got ${positionalArgs.length}',
          location: locationOf(),
        );
      }
      return target.contains(positionalArgs[0]);
    case 'indexOf':
      if (positionalArgs.length != 1) {
        throw ResolveException(
          source,
          'indexOf expects 1 positional arg, got ${positionalArgs.length}',
          location: locationOf(),
        );
      }
      return target.indexOf(positionalArgs[0]);
    case 'join':
      if (positionalArgs.isEmpty) {
        return target.join();
      }
      if (positionalArgs.length == 1) {
        final sep = positionalArgs[0];
        if (sep is! String) {
          throw ResolveException(
            source,
            'join expects String at position 0, got ${sep.runtimeType}',
            location: locationOf(),
          );
        }
        return target.join(sep);
      }
      throw ResolveException(
        source,
        'join expects 0 or 1 positional args, got ${positionalArgs.length}',
        location: locationOf(),
      );
    case 'map':
      _requireArity(
        methodName: 'map',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final fn = _requireClosureArg(
        positionalArgs: positionalArgs,
        index: 0,
        expectedArity: 1,
        methodName: 'map',
        typeName: 'List',
        source: source,
        locationOf: locationOf,
      );
      return <Object?>[for (final e in target) fn.call(<Object?>[e])];
    case 'where':
      _requireArity(
        methodName: 'where',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final fn = _requireClosureArg(
        positionalArgs: positionalArgs,
        index: 0,
        expectedArity: 1,
        methodName: 'where',
        typeName: 'List',
        source: source,
        locationOf: locationOf,
      );
      return <Object?>[
        for (final e in target)
          if (_requireBoolResult(
            result: fn.call(<Object?>[e]),
            methodName: 'where',
            typeName: 'List',
            source: source,
            locationOf: locationOf,
          ))
            e,
      ];
    case 'any':
      _requireArity(
        methodName: 'any',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final fn = _requireClosureArg(
        positionalArgs: positionalArgs,
        index: 0,
        expectedArity: 1,
        methodName: 'any',
        typeName: 'List',
        source: source,
        locationOf: locationOf,
      );
      for (final e in target) {
        if (_requireBoolResult(
          result: fn.call(<Object?>[e]),
          methodName: 'any',
          typeName: 'List',
          source: source,
          locationOf: locationOf,
        )) {
          return true;
        }
      }
      return false;
    case 'every':
      _requireArity(
        methodName: 'every',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final fn = _requireClosureArg(
        positionalArgs: positionalArgs,
        index: 0,
        expectedArity: 1,
        methodName: 'every',
        typeName: 'List',
        source: source,
        locationOf: locationOf,
      );
      for (final e in target) {
        if (!_requireBoolResult(
          result: fn.call(<Object?>[e]),
          methodName: 'every',
          typeName: 'List',
          source: source,
          locationOf: locationOf,
        )) {
          return false;
        }
      }
      return true;
    case 'firstWhere':
      _requireArity(
        methodName: 'firstWhere',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final fn = _requireClosureArg(
        positionalArgs: positionalArgs,
        index: 0,
        expectedArity: 1,
        methodName: 'firstWhere',
        typeName: 'List',
        source: source,
        locationOf: locationOf,
      );
      return target.firstWhere(
        (e) => _requireBoolResult(
          result: fn.call(<Object?>[e]),
          methodName: 'firstWhere',
          typeName: 'List',
          source: source,
          locationOf: locationOf,
        ),
      );
    case 'forEach':
      _requireArity(
        methodName: 'forEach',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final fn = _requireClosureArg(
        positionalArgs: positionalArgs,
        index: 0,
        expectedArity: 1,
        methodName: 'forEach',
        typeName: 'List',
        source: source,
        locationOf: locationOf,
      );
      for (final e in target) {
        fn.call(<Object?>[e]);
      }
      return null;
    case 'fold':
      _requireArity(
        methodName: 'fold',
        expected: 2,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final fn = _requireClosureArg(
        positionalArgs: positionalArgs,
        index: 1,
        expectedArity: 2,
        methodName: 'fold',
        typeName: 'List',
        source: source,
        locationOf: locationOf,
      );
      var acc = positionalArgs[0];
      for (final e in target) {
        acc = fn.call(<Object?>[acc, e]);
      }
      return acc;
    case 'reduce':
      _requireArity(
        methodName: 'reduce',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final fn = _requireClosureArg(
        positionalArgs: positionalArgs,
        index: 0,
        expectedArity: 2,
        methodName: 'reduce',
        typeName: 'List',
        source: source,
        locationOf: locationOf,
      );
      // `target` may be a narrower runtime type (e.g. `List<int>` via
      // covariance) whose `reduce` demands a `(E, E) => E` combiner.
      // Our closure returns `Object?`, so we reduce manually instead of
      // delegating, preserving Dart's empty-list StateError semantics.
      if (target.isEmpty) {
        throw StateError('No element');
      }
      var acc = target.first;
      for (var i = 1; i < target.length; i++) {
        acc = fn.call(<Object?>[acc, target[i]]);
      }
      return acc;
  }

  throw ResolveException(
    source,
    'No built-in method "$methodName" on List',
    location: locationOf(),
  );
}

/// Validates arity for a positional-only method dispatch arm.
void _requireArity({
  required String methodName,
  required int expected,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  if (positionalArgs.length != expected) {
    throw ResolveException(
      source,
      '$methodName expects $expected positional '
      'arg${expected == 1 ? "" : "s"}, got ${positionalArgs.length}',
      location: locationOf(),
    );
  }
}

/// Extracts a [RuneClosure] from [positionalArgs] at [index], validating
/// its presence, runtime type, and parameter arity.
///
/// Three failure modes; all surface as [ResolveException] with a
/// populated [SourceSpan]:
///
/// 1. Missing arg: [positionalArgs] is shorter than `index + 1`.
/// 2. Wrong runtime type: the value at [index] is not a [RuneClosure].
/// 3. Wrong arity: the closure declares a different number of
///    parameters than [expectedArity].
///
/// [typeName] is the receiver type (e.g. `List`) and [methodName] is the
/// member name (e.g. `map`); both are used only for error messaging so
/// the diagnostic reads `List.map expects a closure ...`.
RuneClosure _requireClosureArg({
  required List<Object?> positionalArgs,
  required int index,
  required int expectedArity,
  required String methodName,
  required String typeName,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  if (index >= positionalArgs.length) {
    throw ResolveException(
      source,
      '$typeName.$methodName expects a closure argument at position $index',
      location: locationOf(),
    );
  }
  final raw = positionalArgs[index];
  if (raw is! RuneClosure) {
    throw ResolveException(
      source,
      '$typeName.$methodName expects a closure at position $index; '
      'got ${raw.runtimeType}',
      location: locationOf(),
    );
  }
  if (raw.parameterNames.length != expectedArity) {
    throw ResolveException(
      source,
      '$typeName.$methodName closure expects $expectedArity '
      'parameter${expectedArity == 1 ? "" : "s"}, '
      'got ${raw.parameterNames.length}',
      location: locationOf(),
    );
  }
  return raw;
}

/// Validates that a bool-predicate closure returned a bool. Returns the
/// coerced bool on success; raises [ResolveException] otherwise.
bool _requireBoolResult({
  required Object? result,
  required String methodName,
  required String typeName,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  if (result is! bool) {
    throw ResolveException(
      source,
      '$typeName.$methodName closure must return bool, '
      'got ${result.runtimeType}',
      location: locationOf(),
    );
  }
  return result;
}

Object? _invokeMapMethod({
  required Map<Object?, Object?> target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  switch (methodName) {
    case 'containsKey':
      if (positionalArgs.length != 1) {
        throw ResolveException(
          source,
          'containsKey expects 1 positional arg, '
          'got ${positionalArgs.length}',
          location: locationOf(),
        );
      }
      return target.containsKey(positionalArgs[0]);
    case 'containsValue':
      if (positionalArgs.length != 1) {
        throw ResolveException(
          source,
          'containsValue expects 1 positional arg, '
          'got ${positionalArgs.length}',
          location: locationOf(),
        );
      }
      return target.containsValue(positionalArgs[0]);
  }

  throw ResolveException(
    source,
    'No built-in method "$methodName" on Map',
    location: locationOf(),
  );
}

Object? _invokeNumMethod({
  required num target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  if (positionalArgs.isNotEmpty) {
    throw ResolveException(
      source,
      '$methodName expects 0 positional args, got ${positionalArgs.length}',
      location: locationOf(),
    );
  }
  switch (methodName) {
    case 'abs':
      return target.abs();
    case 'round':
      return target.round();
    case 'floor':
      return target.floor();
    case 'ceil':
      return target.ceil();
    case 'toInt':
      return target.toInt();
    case 'toDouble':
      return target.toDouble();
  }

  throw ResolveException(
    source,
    'No built-in method "$methodName" on num',
    location: locationOf(),
  );
}
