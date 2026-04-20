import 'package:flutter/material.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
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

/// Validates a resolved `suggestionsBuilder` argument for
/// [SearchAnchor] / `SearchAnchor.bar` and returns a [SuggestionsBuilder]
/// that feeds `(BuildContext, SearchController)` into the underlying
/// [RuneClosure].
///
/// The closure is expected to return a list of [Widget]s (typically a
/// list of [ListTile] entries). Non-[Widget] values are silently
/// filtered out, matching the Column/Row children-filter convention. A
/// non-list return raises [ResolveException].
SuggestionsBuilder toSearchSuggestionsBuilder(
  Object? source,
  String widgetName,
) {
  final closure = _requireClosure(source, widgetName, 'suggestionsBuilder', 2);
  return (ctx, controller) {
    final result = closure.call(<Object?>[ctx, controller]);
    if (result is! List) {
      throw ResolveException(
        widgetName,
        '$widgetName.suggestionsBuilder closure must return a List; '
        'got ${result.runtimeType}',
      );
    }
    return result.whereType<Widget>().toList(growable: false);
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

/// Validates a resolved `validator` argument for form-field widgets
/// (`TextFormField`) and returns a typed [FormFieldValidator] of
/// `String` that feeds the current field value into the underlying
/// [RuneClosure].
///
/// The closure signature is `(String?) -> String?`. A non-null return
/// value is displayed by the form field as the validation error; a
/// `null` return signals the field is valid.
///
/// Returns `null` when [source] is `null`, matching Flutter's "no
/// validator attached" semantics. Failure modes:
///
/// 1. [source] is not a [RuneClosure]: [ArgumentException].
/// 2. Closure declares an arity other than 1: [ArgumentException].
/// 3. Closure body evaluates to a non-`String`, non-`null` value at
///    invocation time: [ResolveException].
FormFieldValidator<String>? toValidator(Object? source, String widgetName) {
  if (source == null) return null;
  final closure = _requireClosure(source, widgetName, 'validator', 1);
  return (value) {
    final result = closure.call(<Object?>[value]);
    if (result != null && result is! String) {
      throw ResolveException(
        widgetName,
        '$widgetName.validator closure must return String? '
        '(null = valid); got ${result.runtimeType}',
      );
    }
    return result as String?;
  };
}

/// Validates a resolved `onSaved` / `onFieldSubmitted` argument for
/// form-field widgets and returns a nullable [ValueChanged] of
/// `String?` that feeds the current field value into the underlying
/// [RuneClosure].
///
/// The closure signature is `(String?) -> void`; any return value is
/// discarded. Returns `null` when [source] is `null`, matching
/// Flutter's "no handler attached" semantics.
///
/// Failure modes:
///
/// 1. [source] is not a [RuneClosure]: [ArgumentException].
/// 2. Closure declares an arity other than 1: [ArgumentException].
///
/// [paramName] customizes the diagnostic text so `onSaved` and
/// `onFieldSubmitted` produce distinct error messages when arity or
/// runtime type is wrong.
ValueChanged<String?>? toStringValueChanged(
  Object? source,
  String widgetName, {
  required String paramName,
}) {
  if (source == null) return null;
  final closure = _requireClosure(source, widgetName, paramName, 1);
  return (value) {
    closure.call(<Object?>[value]);
  };
}

/// Validates a resolved `builder` argument for [DragTarget] and returns
/// a [DragTargetBuilder] of `Object?` that feeds
/// `(BuildContext, List<Object?> candidateData, List<dynamic> rejectedData)`
/// into the underlying [RuneClosure].
///
/// Failure modes mirror [toIndexedBuilder]: null / wrong runtime type /
/// wrong arity (expected 3). The returned builder raises
/// [ResolveException] if the closure body yields a non-[Widget].
DragTargetBuilder<Object?> toDragTargetBuilder(
  Object? source,
  String widgetName,
) {
  final closure = _requireClosure(source, widgetName, 'builder', 3);
  return (ctx, candidateData, rejectedData) {
    final result = closure.call(<Object?>[ctx, candidateData, rejectedData]);
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

/// Validates a resolved `onDismissed` argument for [Dismissible] and
/// returns a `ValueChanged<DismissDirection>` that feeds the direction
/// into the underlying [RuneClosure].
///
/// Returns `null` when [source] is `null`, matching Flutter's "no
/// handler attached" semantics. Failure modes:
///
/// 1. [source] is not a [RuneClosure]: [ArgumentException].
/// 2. Closure declares an arity other than 1: [ArgumentException].
ValueChanged<DismissDirection>? toDismissibleCallback(
  Object? source,
  String widgetName,
) {
  if (source == null) return null;
  final closure = _requireClosure(source, widgetName, 'onDismissed', 1);
  return (direction) {
    closure.call(<Object?>[direction]);
  };
}

/// Validates a resolved `onReorder` argument for [ReorderableListView]
/// and returns a [ReorderCallback] `(int oldIndex, int newIndex) -> void`
/// that feeds the two indices into the underlying [RuneClosure].
///
/// Failure modes mirror [toIndexedBuilder]: null / wrong runtime type /
/// wrong arity (expected 2).
ReorderCallback toReorderCallback(Object? source, String widgetName) {
  final closure = _requireClosure(source, widgetName, 'onReorder', 2);
  return (oldIndex, newIndex) {
    closure.call(<Object?>[oldIndex, newIndex]);
  };
}

/// Validates a resolved `onAcceptWithDetails` argument for [DragTarget]
/// and returns a [DragTargetAcceptWithDetails] of `Object` that feeds
/// the single [DragTargetDetails] argument into the underlying
/// [RuneClosure], or dispatches a named event through [events] when
/// [source] is a `String`.
///
/// Returns `null` when [source] is `null`. Failure modes:
///
/// 1. [source] is neither a [String] nor a [RuneClosure]:
///    [ArgumentException].
/// 2. Closure declares an arity other than 1: [ArgumentException].
DragTargetAcceptWithDetails<Object>? toDragAcceptCallback(
  Object? source,
  String widgetName,
  RuneEventDispatcher events,
) {
  if (source == null) return null;
  if (source is String) {
    final eventName = source;
    return (details) => events.dispatch(eventName, <Object?>[details]);
  }
  final closure = _requireClosure(
    source,
    widgetName,
    'onAcceptWithDetails',
    1,
  );
  return (details) {
    closure.call(<Object?>[details]);
  };
}

/// Validates a resolved `onWillAcceptWithDetails` argument for
/// [DragTarget] and returns a [DragTargetWillAcceptWithDetails] of
/// `Object` that feeds the single [DragTargetDetails] argument into the
/// underlying [RuneClosure], or dispatches a named event and returns
/// `true` when [source] is a `String`.
///
/// Returns `null` when [source] is `null`. Failure modes mirror
/// [toDragAcceptCallback]; in addition, the closure body must evaluate
/// to `bool` at invocation time or a [ResolveException] is raised.
DragTargetWillAcceptWithDetails<Object>? toDragWillAcceptCallback(
  Object? source,
  String widgetName,
  RuneEventDispatcher events,
) {
  if (source == null) return null;
  if (source is String) {
    final eventName = source;
    return (details) {
      events.dispatch(eventName, <Object?>[details]);
      return true;
    };
  }
  final closure = _requireClosure(
    source,
    widgetName,
    'onWillAcceptWithDetails',
    1,
  );
  return (details) {
    final result = closure.call(<Object?>[details]);
    if (result is! bool) {
      throw ResolveException(
        widgetName,
        '$widgetName.onWillAcceptWithDetails closure must return bool; '
        'got ${result.runtimeType}',
      );
    }
    return result;
  };
}

/// Validates a resolved `onDragEnd` argument for [Draggable] and
/// [LongPressDraggable] and returns a `ValueChanged<DraggableDetails>`
/// that feeds the completion details into the underlying [RuneClosure].
///
/// Returns `null` when [source] is `null`. Failure modes:
///
/// 1. [source] is not a [RuneClosure]: [ArgumentException].
/// 2. Closure declares an arity other than 1: [ArgumentException].
ValueChanged<DraggableDetails>? toDragEndCallback(
  Object? source,
  String widgetName,
) {
  if (source == null) return null;
  final closure = _requireClosure(source, widgetName, 'onDragEnd', 1);
  return (details) {
    closure.call(<Object?>[details]);
  };
}

/// Validates a resolved `(int, bool) -> void` argument used by
/// [DataColumn].onSort and [ExpansionPanelList].expansionCallback, and
/// returns a Dart `void Function(int, bool)` that feeds the two
/// arguments into the underlying [RuneClosure].
///
/// Returns `null` when [source] is `null`, matching Flutter's "no
/// handler attached" semantics. Failure modes:
///
/// 1. [source] is not a [RuneClosure]: [ArgumentException].
/// 2. Closure declares an arity other than 2: [ArgumentException].
///
/// [paramName] customizes the diagnostic text so `onSort` and
/// `expansionCallback` produce distinct error messages when arity or
/// runtime type is wrong.
// ignore: avoid_positional_boolean_parameters
void Function(int, bool)? toIntBoolCallback(
  Object? source,
  String widgetName, {
  required String paramName,
}) {
  if (source == null) return null;
  final closure = _requireClosure(source, widgetName, paramName, 2);
  return (i, b) {
    closure.call(<Object?>[i, b]);
  };
}

/// Validates a resolved `(int) -> void` argument used by
/// [Stepper].onStepTapped and returns a `ValueChanged<int>` that feeds
/// the tapped step index into the underlying [RuneClosure].
///
/// Returns `null` when [source] is `null`. Failure modes:
///
/// 1. [source] is not a [RuneClosure]: [ArgumentException].
/// 2. Closure declares an arity other than 1: [ArgumentException].
ValueChanged<int>? toIntValueChanged(
  Object? source,
  String widgetName, {
  required String paramName,
}) {
  if (source == null) return null;
  final closure = _requireClosure(source, widgetName, paramName, 1);
  return (i) {
    closure.call(<Object?>[i]);
  };
}

/// Validates a resolved `headerBuilder` argument for [ExpansionPanel]
/// and returns an [ExpansionPanelHeaderBuilder] that feeds
/// `(BuildContext, bool isExpanded)` into the underlying [RuneClosure].
///
/// Failure modes mirror [toIndexedBuilder]: null / wrong runtime type /
/// wrong arity (expected 2). The returned builder raises
/// [ResolveException] if the closure body yields a non-[Widget].
ExpansionPanelHeaderBuilder toExpansionPanelHeaderBuilder(
  Object? source,
  String widgetName,
) {
  final closure = _requireClosure(source, widgetName, 'headerBuilder', 2);
  return (ctx, isExpanded) {
    final result = closure.call(<Object?>[ctx, isExpanded]);
    if (result is! Widget) {
      throw ResolveException(
        widgetName,
        '$widgetName.headerBuilder closure must return a Widget; '
        'got ${result.runtimeType}',
      );
    }
    return result;
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
