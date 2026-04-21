import 'package:flutter/widgets.dart';
import 'package:rune/rune.dart';
// ignore: implementation_imports
import 'package:rune/src/resolver/rune_closure.dart' show RuneClosure;

/// Validates [source] is a [RuneClosure] with the given arity and
/// returns it. Throws [ArgumentException] citing [widgetName] and
/// [slotName] for null / wrong-type / wrong-arity cases.
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

/// Wraps a 3-arity closure into the `(BuildContext, T, Widget?) ->
/// Widget` shape used by `BlocBuilder.builder`.
Widget Function(BuildContext, T, Widget?) toBuilder<T>(
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

/// Wraps a 2-arity closure into the `(BuildContext, T) -> void`
/// shape used by `BlocListener.listener`.
void Function(BuildContext, T) toListener<T>(
  Object? source, {
  required String widgetName,
}) {
  final closure = requireClosure(
    source: source,
    widgetName: widgetName,
    slotName: 'listener',
    expectedArity: 2,
  );
  return (ctx, value) {
    closure.call(<Object?>[ctx, value]);
  };
}

/// Wraps a 1-arity closure into the `(BuildContext) -> T` shape
/// used by `BlocProvider.create`.
T Function(BuildContext) toCreate<T extends Object>(
  Object? source, {
  required String widgetName,
}) {
  final closure = requireClosure(
    source: source,
    widgetName: widgetName,
    slotName: 'create',
    expectedArity: 1,
  );
  return (ctx) {
    final result = closure.call(<Object?>[ctx]);
    if (result is! T) {
      throw ResolveException(
        widgetName,
        '$widgetName.create closure must return a $T; '
        'got ${result.runtimeType}',
      );
    }
    return result;
  };
}
