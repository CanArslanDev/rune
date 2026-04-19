import 'package:flutter/material.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/resolver/rune_closure.dart';

/// Validates a resolved `itemBuilder` argument for lazy-list / grid
/// widgets (`ListView.builder`, `GridView.countBuilder`,
/// `SliverList.builder`, etc.) and returns a typed
/// [IndexedWidgetBuilder] that feeds `(BuildContext, int)` into the
/// underlying [RuneClosure].
///
/// Lives in the `builders/` root rather than inside a specific widget
/// file because the same closure-unwrapping contract is shared by six
/// value builders and one widget builder variant. The architecture
/// invariant forbids `builders/widgets/` and `builders/values/` from
/// importing `src/resolver/`; the single permitted resolver import from
/// `builders/` root is [RuneClosure] itself.
///
/// Failure modes (all surface as [ArgumentException] citing [widgetName]):
///
/// 1. [source] is `null`: missing required argument.
/// 2. [source] is not a [RuneClosure].
/// 3. Closure declares an arity other than 2 (expected `(ctx, index)`).
///
/// The returned builder raises [ResolveException] at invocation time
/// when the closure body resolves to a non-[Widget] value.
IndexedWidgetBuilder toIndexedBuilder(Object? source, String widgetName) {
  final closure = _requireClosure(source, widgetName, 'itemBuilder', 2);
  return (ctx, index) {
    final result = closure.call(<Object?>[ctx, index]);
    if (result is! Widget) {
      throw ResolveException(
        widgetName,
        '$widgetName.itemBuilder closure must return a Widget; '
        'got ${result.runtimeType}',
      );
    }
    return result;
  };
}

/// Validates a resolved `builder` argument for [FutureBuilder] and
/// returns an [AsyncWidgetBuilder] of `Object?` that feeds
/// `(BuildContext, AsyncSnapshot<Object?>)` into the underlying
/// [RuneClosure].
///
/// Failure modes mirror [toIndexedBuilder]: null / wrong runtime type /
/// wrong arity (expected 2). The returned builder raises
/// [ResolveException] if the closure body yields a non-[Widget].
AsyncWidgetBuilder<Object?> toFutureSnapshotBuilder(
  Object? source,
  String widgetName,
) {
  final closure = _requireClosure(source, widgetName, 'builder', 2);
  return (ctx, snapshot) {
    final result = closure.call(<Object?>[ctx, snapshot]);
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

/// Validates a resolved `builder` argument for [StreamBuilder] and
/// returns an [AsyncWidgetBuilder] of `Object?`.
///
/// Identical contract to [toFutureSnapshotBuilder]; split so diagnostic
/// text reads "StreamBuilder.builder" vs "FutureBuilder.builder" when
/// the source gets it wrong.
AsyncWidgetBuilder<Object?> toStreamSnapshotBuilder(
  Object? source,
  String widgetName,
) {
  final closure = _requireClosure(source, widgetName, 'builder', 2);
  return (ctx, snapshot) {
    final result = closure.call(<Object?>[ctx, snapshot]);
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

/// Validates a resolved `builder` argument for [LayoutBuilder] and
/// returns a [LayoutWidgetBuilder] that feeds
/// `(BuildContext, BoxConstraints)` into the underlying [RuneClosure].
LayoutWidgetBuilder toLayoutBuilder(Object? source, String widgetName) {
  final closure = _requireClosure(source, widgetName, 'builder', 2);
  return (ctx, constraints) {
    final result = closure.call(<Object?>[ctx, constraints]);
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

/// Validates a resolved `builder` argument for [OrientationBuilder] and
/// returns an [OrientationWidgetBuilder] that feeds
/// `(BuildContext, Orientation)` into the underlying [RuneClosure].
OrientationWidgetBuilder toOrientationBuilder(
  Object? source,
  String widgetName,
) {
  final closure = _requireClosure(source, widgetName, 'builder', 2);
  return (ctx, orientation) {
    final result = closure.call(<Object?>[ctx, orientation]);
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

/// Validates a resolved single-parameter `(BuildContext) -> Widget`
/// closure and returns a [WidgetBuilder] that feeds `(BuildContext)` to
/// the underlying [RuneClosure].
///
/// Shared by the imperative bridges (`showDialog`, `showModalBottomSheet`)
/// where Flutter's API expects `WidgetBuilder = Widget Function(BuildContext)`.
///
/// Failure modes mirror [toIndexedBuilder]: null / wrong runtime type /
/// wrong arity (expected 1). The returned builder raises
/// [ResolveException] if the closure body yields a non-[Widget].
WidgetBuilder toContextWidgetBuilder(Object? source, String widgetName) {
  final closure = _requireClosure(source, widgetName, 'builder', 1);
  return (ctx) {
    final result = closure.call(<Object?>[ctx]);
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

/// Validates a resolved `itemBuilder` argument for [PopupMenuButton] and
/// returns a [PopupMenuItemBuilder] of `Object?` that feeds
/// `(BuildContext)` into the underlying [RuneClosure].
///
/// The closure is expected to return a list whose entries are
/// [PopupMenuEntry] instances ([PopupMenuItem], [PopupMenuDivider],
/// etc.). Non-entry values are silently filtered out, matching the
/// Column/Row children-filter convention. A non-list return raises
/// [ResolveException].
PopupMenuItemBuilder<Object?> toPopupMenuItemBuilder(
  Object? source,
  String widgetName,
) {
  final closure = _requireClosure(source, widgetName, 'itemBuilder', 1);
  return (ctx) {
    final result = closure.call(<Object?>[ctx]);
    if (result is! List) {
      throw ResolveException(
        widgetName,
        '$widgetName.itemBuilder closure must return a List; '
        'got ${result.runtimeType}',
      );
    }
    return result.whereType<PopupMenuEntry<Object?>>().toList(growable: false);
  };
}

/// Shared guard: extracts a [RuneClosure] of arity [expectedArity] from
/// [source], raising [ArgumentException] citing [widgetName] and
/// [paramName] on any failure (null, wrong runtime type, wrong arity).
RuneClosure _requireClosure(
  Object? source,
  String widgetName,
  String paramName,
  int expectedArity,
) {
  if (source == null) {
    throw ArgumentException(
      widgetName,
      'Missing required argument "$paramName"',
    );
  }
  if (source is! RuneClosure) {
    throw ArgumentException(
      widgetName,
      '`$paramName` must be a closure; got ${source.runtimeType}',
    );
  }
  if (source.parameterNames.length != expectedArity) {
    throw ArgumentException(
      widgetName,
      '`$paramName` closure must accept exactly $expectedArity '
      'parameter${expectedArity == 1 ? "" : "s"}, '
      'got ${source.parameterNames.length}',
    );
  }
  return source;
}
