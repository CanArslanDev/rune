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
import 'package:flutter/material.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/rune_state.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/resolver/rune_closure.dart';

/// Mapping from runtime-target type label to the whitelisted method
/// names dispatched on it. Used by the `_throwUnknownMethod` helper to
/// feed "did you mean ...?" suggestions into [ResolveException].
const Map<String, List<String>> _builtinMethodsByType = <String, List<String>>{
  'String': <String>[
    'toUpperCase',
    'toLowerCase',
    'trim',
    'contains',
    'startsWith',
    'endsWith',
    'split',
    'substring',
    'replaceAll',
    'toString',
  ],
  'List': <String>[
    'contains',
    'indexOf',
    'join',
    'map',
    'where',
    'any',
    'every',
    'firstWhere',
    'forEach',
    'fold',
    'reduce',
    'toString',
  ],
  'Map': <String>['containsKey', 'containsValue', 'toString'],
  'num': <String>[
    'abs',
    'round',
    'floor',
    'ceil',
    'toInt',
    'toDouble',
    'toString',
  ],
  'RuneState': <String>['get', 'has', 'set', 'setMany', 'remove', 'clear'],
  'TextEditingController': <String>['clear', 'dispose'],
  'ScrollController': <String>['jumpTo', 'animateTo', 'dispose'],
  'FocusNode': <String>['requestFocus', 'unfocus', 'dispose'],
  'PageController': <String>['jumpToPage', 'animateToPage', 'dispose'],
  'TabController': <String>['animateTo'],
  'AnimationController': <String>[
    'forward',
    'reverse',
    'stop',
    'reset',
    'repeat',
    'drive',
    'dispose',
  ],
  'Animation': <String>['drive'],
  'Animatable': <String>['animate', 'chain'],
};

/// Mapping from runtime-target type label to the whitelisted property
/// names the built-in resolver exposes. Used by property-access throw
/// sites to surface suggestions on near-miss typos like `.lenght` →
/// `.length`.
const Map<String, List<String>> _builtinPropertiesByType =
    <String, List<String>>{
  'String': <String>['length', 'isEmpty', 'isNotEmpty'],
  'List': <String>['length', 'isEmpty', 'isNotEmpty', 'first', 'last'],
  'Map': <String>['length', 'isEmpty', 'isNotEmpty', 'keys', 'values'],
  'TextEditingController': <String>['text', 'value'],
  'FocusNode': <String>['hasFocus'],
  'TabController': <String>['index'],
  'Animation': <String>[
    'value',
    'status',
    'isAnimating',
    'isCompleted',
    'isDismissed',
  ],
  'AsyncSnapshot': <String>[
    'hasData',
    'data',
    'hasError',
    'error',
    'connectionState',
  ],
  'BoxConstraints': <String>[
    'maxWidth',
    'minWidth',
    'maxHeight',
    'minHeight',
    'biggest',
    'smallest',
  ],
  'ThemeData': <String>[
    'colorScheme',
    'textTheme',
    'brightness',
    'primaryColor',
    'useMaterial3',
    'scaffoldBackgroundColor',
    'cardColor',
    'dividerColor',
  ],
  'ColorScheme': <String>[
    'primary',
    'onPrimary',
    'primaryContainer',
    'onPrimaryContainer',
    'secondary',
    'onSecondary',
    'secondaryContainer',
    'onSecondaryContainer',
    'tertiary',
    'onTertiary',
    'error',
    'onError',
    'surface',
    'onSurface',
    'surfaceContainerHighest',
    'outline',
    'shadow',
    'inverseSurface',
    'brightness',
  ],
  'TextTheme': <String>[
    'displayLarge',
    'displayMedium',
    'displaySmall',
    'headlineLarge',
    'headlineMedium',
    'headlineSmall',
    'titleLarge',
    'titleMedium',
    'titleSmall',
    'bodyLarge',
    'bodyMedium',
    'bodySmall',
    'labelLarge',
    'labelMedium',
    'labelSmall',
  ],
  'MediaQueryData': <String>[
    'size',
    'orientation',
    'padding',
    'viewInsets',
    'viewPadding',
    'devicePixelRatio',
    'textScaler',
    'platformBrightness',
  ],
  'Size': <String>[
    'width',
    'height',
    'shortestSide',
    'longestSide',
    'aspectRatio',
    'isEmpty',
  ],
  'EdgeInsets': <String>[
    'left',
    'top',
    'right',
    'bottom',
    'horizontal',
    'vertical',
  ],
  'Route': <String>[
    'isFirst',
    'isActive',
    'isCurrent',
    'settings',
  ],
  'RouteSettings': <String>[
    'name',
    'arguments',
  ],
};

/// Returns the whitelisted property names on [typeLabel], or an empty
/// iterable when [typeLabel] is not a built-in target type. Consumed by
/// `PropertyResolver` when composing "did you mean ...?" suggestions.
Iterable<String> builtinPropertiesFor(String typeLabel) {
  return _builtinPropertiesByType[typeLabel] ?? const <String>[];
}

/// Chooses a short, human-readable type label for a built-in target
/// value. Follows the runtime-type check order used by
/// [resolveBuiltinProperty] so the label aligns with how dispatch
/// actually proceeds.
///
/// Returns `null` when [target] is not a recognized built-in target
/// type. Callers fall back to `target.runtimeType.toString()` for
/// diagnostics.
String? builtinTargetTypeLabel(Object? target) {
  if (target is String) return 'String';
  if (target is List<Object?>) return 'List';
  if (target is Map<Object?, Object?>) return 'Map';
  if (target is num) return 'num';
  if (target is RuneState) return 'RuneState';
  if (target is TextEditingController) return 'TextEditingController';
  if (target is ScrollController) return 'ScrollController';
  if (target is FocusNode) return 'FocusNode';
  if (target is PageController) return 'PageController';
  if (target is TabController) return 'TabController';
  if (target is AnimationController) return 'AnimationController';
  if (target is Animation<double>) return 'Animation';
  if (target is Animatable<Object?>) return 'Animatable';
  if (target is AsyncSnapshot<Object?>) return 'AsyncSnapshot';
  if (target is BoxConstraints) return 'BoxConstraints';
  if (target is ThemeData) return 'ThemeData';
  if (target is ColorScheme) return 'ColorScheme';
  if (target is TextTheme) return 'TextTheme';
  if (target is MediaQueryData) return 'MediaQueryData';
  if (target is Size) return 'Size';
  if (target is EdgeInsets) return 'EdgeInsets';
  if (target is Route<Object?>) return 'Route';
  if (target is RouteSettings) return 'RouteSettings';
  return null;
}

/// Raises a [ResolveException] reporting that [methodName] is not
/// whitelisted on [typeLabel], with a Levenshtein-based suggestion
/// drawn from the built-in method table for [typeLabel] when one is
/// available. Shared by every `_invokeXxxMethod` helper so the
/// diagnostic format stays uniform.
Never _throwUnknownMethod({
  required String typeLabel,
  required String methodName,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  final candidates = _builtinMethodsByType[typeLabel] ?? const <String>[];
  throw ResolveException.withSuggestion(
    source: source,
    baseMessage: 'No built-in method "$methodName" on $typeLabel',
    candidate: methodName,
    candidates: candidates,
    location: locationOf(),
  );
}

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
/// - `TextEditingController`: `text`, `value`
/// - `FocusNode`: `hasFocus`
/// - `TabController`: `index`
/// - `Animation<double>` (v1.9.0): `value`, `status`, `isAnimating`,
///   `isCompleted`, `isDismissed`
/// - `AsyncSnapshot`: `hasData`, `data`, `hasError`, `error`,
///   `connectionState`
/// - `BoxConstraints`: `maxWidth`, `minWidth`, `maxHeight`, `minHeight`,
///   `biggest`, `smallest`
/// - `ThemeData` (v1.4.0): `colorScheme`, `textTheme`, `brightness`,
///   `primaryColor`, `useMaterial3`, `scaffoldBackgroundColor`,
///   `cardColor`, `dividerColor`
/// - `ColorScheme` (v1.4.0): `primary`, `onPrimary`, `primaryContainer`,
///   `onPrimaryContainer`, `secondary`, `onSecondary`,
///   `secondaryContainer`, `onSecondaryContainer`, `tertiary`,
///   `onTertiary`, `error`, `onError`, `surface`, `onSurface`,
///   `surfaceContainerHighest`, `outline`, `shadow`, `inverseSurface`,
///   `brightness`
/// - `TextTheme` (v1.4.0): `displayLarge`..`displaySmall`,
///   `headlineLarge`..`headlineSmall`, `titleLarge`..`titleSmall`,
///   `bodyLarge`..`bodySmall`, `labelLarge`..`labelSmall`
/// - `MediaQueryData` (v1.4.0): `size`, `orientation`, `padding`,
///   `viewInsets`, `viewPadding`, `devicePixelRatio`, `textScaler`,
///   `platformBrightness`
/// - `Size` (v1.4.0): `width`, `height`, `shortestSide`, `longestSide`,
///   `aspectRatio`, `isEmpty`
/// - `EdgeInsets` (v1.4.0): `left`, `top`, `right`, `bottom`,
///   `horizontal`, `vertical`
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
  // Controller getters (v1.1.0). Every getter is side-effect-free.
  if (target is TextEditingController) {
    return switch (propertyName) {
      'text' => (true, target.text),
      'value' => (true, target.value),
      _ => (false, null),
    };
  }
  if (target is FocusNode) {
    return switch (propertyName) {
      'hasFocus' => (true, target.hasFocus),
      _ => (false, null),
    };
  }
  if (target is TabController) {
    return switch (propertyName) {
      'index' => (true, target.index),
      _ => (false, null),
    };
  }
  // Animation property whitelist (v1.9.0). AnimationController is a
  // subtype of Animation<double>, so checking Animation<double> first
  // covers both. Every getter is side-effect-free and cheap.
  if (target is Animation<double>) {
    return switch (propertyName) {
      'value' => (true, target.value),
      'status' => (true, target.status),
      'isAnimating' => (true, target.isAnimating),
      'isCompleted' => (true, target.isCompleted),
      'isDismissed' => (true, target.isDismissed),
      _ => (false, null),
    };
  }
  // Closure-builder payload types (v1.2.0). Every getter is
  // side-effect-free. AsyncSnapshot is generic in Dart; Rune's source
  // layer treats its payload as Object? because v1.2.0 has no generics
  // syntax, so we destructure via the AsyncSnapshot<Object?>-typed view.
  if (target is AsyncSnapshot<Object?>) {
    return switch (propertyName) {
      'hasData' => (true, target.hasData),
      'data' => (true, target.data),
      'hasError' => (true, target.hasError),
      'error' => (true, target.error),
      'connectionState' => (true, target.connectionState),
      _ => (false, null),
    };
  }
  if (target is BoxConstraints) {
    return switch (propertyName) {
      'maxWidth' => (true, target.maxWidth),
      'minWidth' => (true, target.minWidth),
      'maxHeight' => (true, target.maxHeight),
      'minHeight' => (true, target.minHeight),
      'biggest' => (true, target.biggest),
      'smallest' => (true, target.smallest),
      _ => (false, null),
    };
  }
  // Theme-related read-only value types (v1.4.0). Rune source has no
  // mutation API for these; the whitelist exposes the commonly-consumed
  // slots so templates can style off of a live ThemeData reached via
  // Theme.of(context).
  if (target is ThemeData) {
    return switch (propertyName) {
      'colorScheme' => (true, target.colorScheme),
      'textTheme' => (true, target.textTheme),
      'brightness' => (true, target.brightness),
      'primaryColor' => (true, target.primaryColor),
      'useMaterial3' => (true, target.useMaterial3),
      'scaffoldBackgroundColor' => (true, target.scaffoldBackgroundColor),
      'cardColor' => (true, target.cardColor),
      'dividerColor' => (true, target.dividerColor),
      _ => (false, null),
    };
  }
  if (target is ColorScheme) {
    return switch (propertyName) {
      'primary' => (true, target.primary),
      'onPrimary' => (true, target.onPrimary),
      'primaryContainer' => (true, target.primaryContainer),
      'onPrimaryContainer' => (true, target.onPrimaryContainer),
      'secondary' => (true, target.secondary),
      'onSecondary' => (true, target.onSecondary),
      'secondaryContainer' => (true, target.secondaryContainer),
      'onSecondaryContainer' => (true, target.onSecondaryContainer),
      'tertiary' => (true, target.tertiary),
      'onTertiary' => (true, target.onTertiary),
      'error' => (true, target.error),
      'onError' => (true, target.onError),
      'surface' => (true, target.surface),
      'onSurface' => (true, target.onSurface),
      'surfaceContainerHighest' => (true, target.surfaceContainerHighest),
      'outline' => (true, target.outline),
      'shadow' => (true, target.shadow),
      'inverseSurface' => (true, target.inverseSurface),
      'brightness' => (true, target.brightness),
      _ => (false, null),
    };
  }
  if (target is TextTheme) {
    return switch (propertyName) {
      'displayLarge' => (true, target.displayLarge),
      'displayMedium' => (true, target.displayMedium),
      'displaySmall' => (true, target.displaySmall),
      'headlineLarge' => (true, target.headlineLarge),
      'headlineMedium' => (true, target.headlineMedium),
      'headlineSmall' => (true, target.headlineSmall),
      'titleLarge' => (true, target.titleLarge),
      'titleMedium' => (true, target.titleMedium),
      'titleSmall' => (true, target.titleSmall),
      'bodyLarge' => (true, target.bodyLarge),
      'bodyMedium' => (true, target.bodyMedium),
      'bodySmall' => (true, target.bodySmall),
      'labelLarge' => (true, target.labelLarge),
      'labelMedium' => (true, target.labelMedium),
      'labelSmall' => (true, target.labelSmall),
      _ => (false, null),
    };
  }
  if (target is MediaQueryData) {
    return switch (propertyName) {
      'size' => (true, target.size),
      'orientation' => (true, target.orientation),
      'padding' => (true, target.padding),
      'viewInsets' => (true, target.viewInsets),
      'viewPadding' => (true, target.viewPadding),
      'devicePixelRatio' => (true, target.devicePixelRatio),
      'textScaler' => (true, target.textScaler),
      'platformBrightness' => (true, target.platformBrightness),
      _ => (false, null),
    };
  }
  if (target is Size) {
    return switch (propertyName) {
      'width' => (true, target.width),
      'height' => (true, target.height),
      'shortestSide' => (true, target.shortestSide),
      'longestSide' => (true, target.longestSide),
      'aspectRatio' => (true, target.aspectRatio),
      'isEmpty' => (true, target.isEmpty),
      _ => (false, null),
    };
  }
  if (target is EdgeInsets) {
    return switch (propertyName) {
      'left' => (true, target.left),
      'top' => (true, target.top),
      'right' => (true, target.right),
      'bottom' => (true, target.bottom),
      'horizontal' => (true, target.horizontal),
      'vertical' => (true, target.vertical),
      _ => (false, null),
    };
  }
  // Route whitelist (v1.12.0). Enables `Navigator.popUntil((r) =>
  // r.isFirst)` and similar predicates to work with the built-in
  // resolver path without custom data bridges.
  if (target is Route<Object?>) {
    return switch (propertyName) {
      'isFirst' => (true, target.isFirst),
      'isActive' => (true, target.isActive),
      'isCurrent' => (true, target.isCurrent),
      'settings' => (true, target.settings),
      _ => (false, null),
    };
  }
  if (target is RouteSettings) {
    return switch (propertyName) {
      'name' => (true, target.name),
      'arguments' => (true, target.arguments),
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
/// - `TextEditingController`: `clear`, `dispose` (0 args).
/// - `ScrollController`: `jumpTo(num)`; `animateTo(num, Duration, Curve)`;
///   `dispose` (0 args).
/// - `FocusNode`: `requestFocus`, `unfocus`, `dispose` (0 args).
/// - `PageController`: `jumpToPage(int)`;
///   `animateToPage(int, Duration, Curve)`; `dispose` (0 args).
/// - `TabController`: `animateTo(int)`.
/// - `AnimationController` (v1.9.0): `forward([num?])`, `reverse([num?])`,
///   `stop`, `reset` (0 args); `repeat([bool?])`; `dispose` (0 args).
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
  if (target is TextEditingController) {
    return _invokeTextEditingControllerMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }
  if (target is ScrollController) {
    return _invokeScrollControllerMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }
  if (target is FocusNode) {
    return _invokeFocusNodeMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }
  if (target is PageController) {
    return _invokePageControllerMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }
  if (target is TabController) {
    return _invokeTabControllerMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }
  // Animation controller method whitelist (v1.9.0). Must precede the
  // generic Animation<double> check in the property resolver; here it
  // covers the full controller mutation surface.
  if (target is AnimationController) {
    return _invokeAnimationControllerMethod(
      target: target,
      methodName: methodName,
      positionalArgs: positionalArgs,
      source: source,
      locationOf: locationOf,
    );
  }
  // Animatable method whitelist (v1.12.0). Covers Tween / CurveTween /
  // any composed Animatable: `tween.animate(parent)` returns a live
  // Animation<T>, and `tween.chain(next)` produces a composed Animatable.
  // Tween is itself an Animatable<T>, so this arm matches any untyped
  // Rune tween as well as the built-in ColorTween. Check is gated on
  // Animatable<Object?> to admit the widest runtime type.
  if (target is Animatable<Object?>) {
    return _invokeAnimatableMethod(
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

  _throwUnknownMethod(
    typeLabel: 'RuneState',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
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

  _throwUnknownMethod(
    typeLabel: 'String',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
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

  _throwUnknownMethod(
    typeLabel: 'List',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
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

  _throwUnknownMethod(
    typeLabel: 'Map',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
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

  _throwUnknownMethod(
    typeLabel: 'num',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
  );
}

/// Shared arity guard for positional-only controller method dispatch.
void _requireControllerArity({
  required String typeName,
  required String methodName,
  required int expected,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  if (positionalArgs.length != expected) {
    throw ResolveException(
      source,
      '$typeName.$methodName expects $expected positional '
      'arg${expected == 1 ? "" : "s"}, got ${positionalArgs.length}',
      location: locationOf(),
    );
  }
}

/// Extracts a value at [index] from [positionalArgs], enforcing its
/// runtime type [T]. Used by controller method dispatchers for
/// arg-type validation with uniform diagnostics.
T _requireControllerArg<T>({
  required String typeName,
  required String methodName,
  required int index,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  final v = positionalArgs[index];
  if (v is! T) {
    throw ResolveException(
      source,
      '$typeName.$methodName expects $T at position $index, '
      'got ${v.runtimeType}',
      location: locationOf(),
    );
  }
  return v;
}

Object? _invokeTextEditingControllerMethod({
  required TextEditingController target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  switch (methodName) {
    case 'clear':
      _requireControllerArity(
        typeName: 'TextEditingController',
        methodName: 'clear',
        expected: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.clear();
      return null;
    case 'dispose':
      _requireControllerArity(
        typeName: 'TextEditingController',
        methodName: 'dispose',
        expected: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.dispose();
      return null;
  }

  _throwUnknownMethod(
    typeLabel: 'TextEditingController',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
  );
}

Object? _invokeScrollControllerMethod({
  required ScrollController target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  switch (methodName) {
    case 'jumpTo':
      _requireControllerArity(
        typeName: 'ScrollController',
        methodName: 'jumpTo',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final offset = _requireControllerArg<num>(
        typeName: 'ScrollController',
        methodName: 'jumpTo',
        index: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.jumpTo(offset.toDouble());
      return null;
    case 'animateTo':
      _requireControllerArity(
        typeName: 'ScrollController',
        methodName: 'animateTo',
        expected: 3,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final offset = _requireControllerArg<num>(
        typeName: 'ScrollController',
        methodName: 'animateTo',
        index: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final duration = _requireControllerArg<Duration>(
        typeName: 'ScrollController',
        methodName: 'animateTo',
        index: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final curve = _requireControllerArg<Curve>(
        typeName: 'ScrollController',
        methodName: 'animateTo',
        index: 2,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      return target.animateTo(
        offset.toDouble(),
        duration: duration,
        curve: curve,
      );
    case 'dispose':
      _requireControllerArity(
        typeName: 'ScrollController',
        methodName: 'dispose',
        expected: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.dispose();
      return null;
  }

  _throwUnknownMethod(
    typeLabel: 'ScrollController',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
  );
}

Object? _invokeFocusNodeMethod({
  required FocusNode target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  switch (methodName) {
    case 'requestFocus':
      _requireControllerArity(
        typeName: 'FocusNode',
        methodName: 'requestFocus',
        expected: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.requestFocus();
      return null;
    case 'unfocus':
      _requireControllerArity(
        typeName: 'FocusNode',
        methodName: 'unfocus',
        expected: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.unfocus();
      return null;
    case 'dispose':
      _requireControllerArity(
        typeName: 'FocusNode',
        methodName: 'dispose',
        expected: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.dispose();
      return null;
  }

  _throwUnknownMethod(
    typeLabel: 'FocusNode',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
  );
}

Object? _invokePageControllerMethod({
  required PageController target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  switch (methodName) {
    case 'jumpToPage':
      _requireControllerArity(
        typeName: 'PageController',
        methodName: 'jumpToPage',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final page = _requireControllerArg<int>(
        typeName: 'PageController',
        methodName: 'jumpToPage',
        index: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.jumpToPage(page);
      return null;
    case 'animateToPage':
      _requireControllerArity(
        typeName: 'PageController',
        methodName: 'animateToPage',
        expected: 3,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final page = _requireControllerArg<int>(
        typeName: 'PageController',
        methodName: 'animateToPage',
        index: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final duration = _requireControllerArg<Duration>(
        typeName: 'PageController',
        methodName: 'animateToPage',
        index: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final curve = _requireControllerArg<Curve>(
        typeName: 'PageController',
        methodName: 'animateToPage',
        index: 2,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      return target.animateToPage(
        page,
        duration: duration,
        curve: curve,
      );
    case 'dispose':
      _requireControllerArity(
        typeName: 'PageController',
        methodName: 'dispose',
        expected: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.dispose();
      return null;
  }

  _throwUnknownMethod(
    typeLabel: 'PageController',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
  );
}

/// Dispatch arm for [AnimationController] (v1.9.0). Covers the full
/// playback surface: `forward`, `reverse`, `stop`, `reset`, `repeat`,
/// and `dispose`. `forward`, `reverse`, `stop`, and `reset` accept an
/// optional leading `num` for the `from` parameter; `repeat` accepts
/// an optional `bool` for `reverse` in its single-positional form.
/// Named arguments are rejected at the top of [invokeBuiltinMethod] for
/// uniformity with the rest of the controller whitelist.
Object? _invokeAnimationControllerMethod({
  required AnimationController target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  double? optionalFrom(String method) {
    if (positionalArgs.isEmpty) return null;
    if (positionalArgs.length > 1) {
      throw ResolveException(
        source,
        'AnimationController.$method expects 0 or 1 positional '
        'arg, got ${positionalArgs.length}',
        location: locationOf(),
      );
    }
    final raw = positionalArgs[0];
    if (raw is! num) {
      throw ResolveException(
        source,
        'AnimationController.$method expects num at position 0, '
        'got ${raw.runtimeType}',
        location: locationOf(),
      );
    }
    return raw.toDouble();
  }

  switch (methodName) {
    case 'forward':
      return target.forward(from: optionalFrom('forward'));
    case 'reverse':
      return target.reverse(from: optionalFrom('reverse'));
    case 'stop':
      if (positionalArgs.isNotEmpty) {
        throw ResolveException(
          source,
          'AnimationController.stop expects 0 positional args, '
          'got ${positionalArgs.length}',
          location: locationOf(),
        );
      }
      target.stop();
      return null;
    case 'reset':
      if (positionalArgs.isNotEmpty) {
        throw ResolveException(
          source,
          'AnimationController.reset expects 0 positional args, '
          'got ${positionalArgs.length}',
          location: locationOf(),
        );
      }
      target.reset();
      return null;
    case 'repeat':
      if (positionalArgs.isEmpty) {
        return target.repeat();
      }
      if (positionalArgs.length == 1) {
        final raw = positionalArgs[0];
        if (raw is! bool) {
          throw ResolveException(
            source,
            'AnimationController.repeat expects bool at position 0 '
            '(reverse), got ${raw.runtimeType}',
            location: locationOf(),
          );
        }
        return target.repeat(reverse: raw);
      }
      throw ResolveException(
        source,
        'AnimationController.repeat expects 0 or 1 positional args, '
        'got ${positionalArgs.length}',
        location: locationOf(),
      );
    case 'drive':
      _requireControllerArity(
        typeName: 'AnimationController',
        methodName: 'drive',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final raw = positionalArgs[0];
      if (raw is! Animatable<Object?>) {
        throw ResolveException(
          source,
          'AnimationController.drive expects an Animatable (e.g. Tween, '
          'CurveTween) at position 0, got ${raw.runtimeType}',
          location: locationOf(),
        );
      }
      return target.drive<Object?>(raw);
    case 'dispose':
      _requireControllerArity(
        typeName: 'AnimationController',
        methodName: 'dispose',
        expected: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.dispose();
      return null;
  }

  _throwUnknownMethod(
    typeLabel: 'AnimationController',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
  );
}

/// Dispatch arm for [Animatable] (v1.12.0). Covers `Tween.animate(parent)`
/// which returns a live `Animation<T>` driven by `parent`, and
/// `Animatable.chain(next)` which returns a composed `Animatable<T>`.
/// Both methods are pure: they produce new values without mutating
/// either receiver or argument.
Object? _invokeAnimatableMethod({
  required Animatable<Object?> target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  switch (methodName) {
    case 'animate':
      _requireControllerArity(
        typeName: 'Animatable',
        methodName: 'animate',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final raw = positionalArgs[0];
      if (raw is! Animation<double>) {
        throw ResolveException(
          source,
          'Animatable.animate expects an Animation<double> (e.g. an '
          'AnimationController, CurvedAnimation) at position 0, got '
          '${raw.runtimeType}',
          location: locationOf(),
        );
      }
      return target.animate(raw);
    case 'chain':
      _requireControllerArity(
        typeName: 'Animatable',
        methodName: 'chain',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final raw = positionalArgs[0];
      if (raw is! Animatable<double>) {
        throw ResolveException(
          source,
          'Animatable.chain expects an Animatable<double> at position 0, '
          'got ${raw.runtimeType}',
          location: locationOf(),
        );
      }
      return target.chain(raw);
  }

  _throwUnknownMethod(
    typeLabel: 'Animatable',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
  );
}

/// Dispatch arm for [TabController]. [TabController] is not currently
/// constructable from source (it requires a `TickerProvider`), but an
/// instance passed through `RuneView.data` can still receive method
/// calls. Ships for parity with the shipped getter whitelist entry
/// (`.index`) and in anticipation of v1.9.0's vsync story.
Object? _invokeTabControllerMethod({
  required TabController target,
  required String methodName,
  required List<Object?> positionalArgs,
  required String source,
  required SourceSpan Function() locationOf,
}) {
  switch (methodName) {
    case 'animateTo':
      _requireControllerArity(
        typeName: 'TabController',
        methodName: 'animateTo',
        expected: 1,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      final page = _requireControllerArg<int>(
        typeName: 'TabController',
        methodName: 'animateTo',
        index: 0,
        positionalArgs: positionalArgs,
        source: source,
        locationOf: locationOf,
      );
      target.animateTo(page);
      return null;
  }

  _throwUnknownMethod(
    typeLabel: 'TabController',
    methodName: methodName,
    source: source,
    locationOf: locationOf,
  );
}
