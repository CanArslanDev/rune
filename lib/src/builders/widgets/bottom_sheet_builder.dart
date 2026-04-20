import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [BottomSheet], the persistent (non-modal) sheet
/// surface (v1.12.0). Prefer `showModalBottomSheet(...)` for modal
/// dialog-style sheets; this builder ships the non-modal variant for
/// cases where the sheet is embedded in the tree directly.
///
/// Source arguments:
/// - `onClosing` (required, `String` event name or `RuneClosure`). Called
///   when the sheet begins its close animation. Flutter requires this
///   slot; a missing value raises [ArgumentException].
/// - `builder` (required, closure `(ctx) => Widget`).
/// - `backgroundColor` ([Color]?).
/// - `elevation` ([num]? coerced to double).
/// - `shape` ([ShapeBorder]?).
/// - `enableDrag` ([bool]?). Defaults to `true`.
/// - `showDragHandle` ([bool]?).
final class BottomSheetBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const BottomSheetBuilder();

  @override
  String get typeName => 'BottomSheet';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final onClosingSource = args.named['onClosing'];
    if (onClosingSource == null) {
      throw const ArgumentException(
        'BottomSheet',
        'Missing required argument "onClosing"',
      );
    }
    final onClosing = voidEventCallback(onClosingSource, ctx.events);
    if (onClosing == null) {
      throw const ArgumentException(
        'BottomSheet',
        '`onClosing` must be a String event name or a closure '
        '(e.g. () => ...); got null',
      );
    }
    final builder = toContextWidgetBuilder(
      args.named['builder'],
      'BottomSheet',
    );
    return BottomSheet(
      onClosing: onClosing,
      builder: builder,
      backgroundColor: args.get<Color>('backgroundColor'),
      elevation: args.get<num>('elevation')?.toDouble(),
      shape: args.get<ShapeBorder>('shape'),
      enableDrag: args.getOr<bool>('enableDrag', true),
      showDragHandle: args.get<bool>('showDragHandle'),
    );
  }
}
