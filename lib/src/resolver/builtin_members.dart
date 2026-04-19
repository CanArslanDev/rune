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
import 'package:rune/src/core/source_span.dart';

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
///   `String` arg, default separator `''`).
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

  throw ResolveException(
    source,
    'No built-in method "$methodName" on ${target.runtimeType}',
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
  }

  throw ResolveException(
    source,
    'No built-in method "$methodName" on List',
    location: locationOf(),
  );
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
