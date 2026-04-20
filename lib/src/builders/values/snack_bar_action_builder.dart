import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SnackBarAction] as a value (v1.12.0). Passed as the `action:`
/// slot on `SnackBar(...)`.
///
/// Source arguments:
/// - `label` (required, [String]).
/// - `onPressed` (required, `String` event name or `RuneClosure`).
/// - `textColor` ([Color]?).
/// - `disabledTextColor` ([Color]?).
final class SnackBarActionBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const SnackBarActionBuilder();

  @override
  String get typeName => 'SnackBarAction';

  @override
  String? get constructorName => null;

  @override
  SnackBarAction build(ResolvedArguments args, RuneContext ctx) {
    final onPressedSource = args.named['onPressed'];
    if (onPressedSource == null) {
      throw const ArgumentException(
        'SnackBarAction',
        'Missing required argument "onPressed"',
      );
    }
    final onPressed = voidEventCallback(onPressedSource, ctx.events);
    if (onPressed == null) {
      throw const ArgumentException(
        'SnackBarAction',
        '`onPressed` must be a String event name or a closure '
        '(e.g. () => ...); got null',
      );
    }
    return SnackBarAction(
      label: args.require<String>('label', source: 'SnackBarAction'),
      onPressed: onPressed,
      textColor: args.get<Color>('textColor'),
      disabledTextColor: args.get<Color>('disabledTextColor'),
    );
  }
}
