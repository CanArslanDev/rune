import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material 3 [FilledButton].
///
/// Source arguments:
/// - `onPressed` (`String` event name or `RuneClosure`) - optional. A
///   missing or explicitly-null value leaves `FilledButton.onPressed`
///   null (disabled button).
/// - `child` ([Widget]?) - optional. Falls back to an empty `SizedBox`
///   so source that omits the label still yields a valid widget.
///
/// Shape-specific slots (`style`, `clipBehavior`, etc.) are intentionally
/// deferred; theme-level styling via `Theme.of(context)` covers most
/// templating needs.
final class FilledButtonBuilder implements RuneWidgetBuilder {
  /// Const constructor - the builder is stateless.
  const FilledButtonBuilder();

  @override
  String get typeName => 'FilledButton';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return FilledButton(
      onPressed: voidEventCallback(args.named['onPressed'], ctx.events),
      child: args.get<Widget>('child') ?? const SizedBox.shrink(),
    );
  }
}
