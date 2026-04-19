import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material 3 [SegmentedButton] parametric on [Object?].
///
/// Source arguments:
/// - `segments` (`List<ButtonSegment>`, required). Non-[ButtonSegment]
///   entries are silently filtered out, matching the Column/Row
///   children-filter convention.
/// - `selected` ([Iterable]? - typically a literal set `{v1, v2}` or a
///   list from data). Required by Flutter's [SegmentedButton.selected];
///   a missing value is normalised to an empty set.
/// - `onSelectionChanged` (`String` event name or `RuneClosure` of
///   arity 1) - optional. The callback receives the freshly-selected
///   `Set<Object?>` as its sole argument.
/// - `multiSelectionEnabled` ([bool]?). Defaults to `false`.
/// - `emptySelectionAllowed` ([bool]?). Defaults to `false`.
/// - `showSelectedIcon` ([bool]?). Defaults to `true`.
final class SegmentedButtonBuilder implements RuneWidgetBuilder {
  /// Const constructor - the builder is stateless.
  const SegmentedButtonBuilder();

  @override
  String get typeName => 'SegmentedButton';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawSegments = args.get<List<Object?>>('segments');
    final segments = rawSegments
            ?.whereType<ButtonSegment<Object?>>()
            .toList(growable: false) ??
        const <ButtonSegment<Object?>>[];
    final rawSelected = args.named['selected'];
    final selected = <Object?>{
      if (rawSelected is Iterable) ...rawSelected,
    };
    return SegmentedButton<Object?>(
      segments: segments,
      selected: selected,
      onSelectionChanged: valueEventCallback<Set<Object?>>(
        args.named['onSelectionChanged'],
        ctx.events,
      ),
      multiSelectionEnabled:
          args.getOr<bool>('multiSelectionEnabled', false),
      emptySelectionAllowed: args.getOr<bool>('emptySelectionAllowed', false),
      showSelectedIcon: args.getOr<bool>('showSelectedIcon', true),
    );
  }
}
