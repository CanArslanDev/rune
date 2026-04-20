import 'package:flutter/widgets.dart';
import 'package:rune/rune.dart';
// ignore: implementation_imports
import 'package:rune/src/resolver/rune_closure.dart' show RuneClosure;

/// Validates [source] is a [RuneClosure] with the given [expectedArity]
/// and returns it. Throws [ArgumentException] citing [widgetName] and
/// [slotName] for null / wrong-type / wrong-arity cases.
///
/// Mirrors the private `_requireClosure` helper used in the main
/// `rune` package's closure-builder-helpers module. Duplicated here
/// because that helper is not exported from the barrel; keeping a
/// local copy is simpler than layering public-API changes on top of
/// the main package for a single bridge.
RuneClosure requireClosure({
  required Object? source,
  required String widgetName,
  required String slotName,
  required int expectedArity,
}) {
  if (source == null) {
    throw ArgumentException(
      widgetName,
      '$widgetName.$slotName is required.',
    );
  }
  if (source is! RuneClosure) {
    throw ArgumentException(
      widgetName,
      '$widgetName.$slotName must be a closure; got ${source.runtimeType}.',
    );
  }
  if (source.parameterNames.length != expectedArity) {
    throw ArgumentException(
      widgetName,
      '$widgetName.$slotName closure must take $expectedArity '
      'argument(s); got ${source.parameterNames.length}.',
    );
  }
  return source;
}

/// Wraps a [RuneClosure] into a Flutter-shaped `(BuildContext) -> T`
/// factory for use as `ChangeNotifierProvider.create`. Verifies the
/// closure body resolves to the requested type `T` and surfaces
/// [ResolveException] otherwise. Exposed for test reuse.
T Function(BuildContext) toContextFactory<T extends Object>(
  Object? source, {
  required String widgetName,
  required String slotName,
}) {
  final closure = requireClosure(
    source: source,
    widgetName: widgetName,
    slotName: slotName,
    expectedArity: 1,
  );
  return (ctx) {
    final result = closure.call(<Object?>[ctx]);
    if (result is! T) {
      throw ResolveException(
        widgetName,
        '$widgetName.$slotName closure must return a $T; '
        'got ${result.runtimeType}',
      );
    }
    return result;
  };
}

/// Wraps a 3-arity [RuneClosure] into the `(BuildContext, T, Widget?)
/// -> Widget` shape used by `Consumer.builder` and
/// `Selector.builder`.
///
/// The closure body is expected to return a [Widget]; non-Widget
/// return values surface as [ResolveException] at invocation time.
Widget Function(BuildContext, T, Widget?) toConsumerBuilder<T>(
  Object? source, {
  required String widgetName,
}) {
  final closure = requireClosure(
    source: source,
    widgetName: widgetName,
    slotName: 'builder',
    expectedArity: 3,
  );
  return (ctx, value, child) {
    final result = closure.call(<Object?>[ctx, value, child]);
    if (result is! Widget) {
      throw ResolveException(
        widgetName,
        '$widgetName.builder closure must return a Widget; '
        'got ${result.runtimeType}',
      );
    }
    return result;
  };
}

/// Wraps a 2-arity [RuneClosure] into the `(BuildContext, T) -> R`
/// shape used by `Selector.selector`. Returns the raw value because
/// the selector's result is any value, not a widget.
Object? Function(BuildContext, T) toSelectorSelector<T>(
  Object? source, {
  required String widgetName,
}) {
  final closure = requireClosure(
    source: source,
    widgetName: widgetName,
    slotName: 'selector',
    expectedArity: 2,
  );
  return (ctx, value) => closure.call(<Object?>[ctx, value]);
}
