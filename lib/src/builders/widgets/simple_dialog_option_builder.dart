import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [SimpleDialogOption] - an individual tappable entry
/// intended for the `children` list of a [SimpleDialog].
///
/// Supported named arguments:
/// - `child` ([Widget]?) - the option's display widget, typically a
///   `Text`.
/// - `onPressed` (`String` event name or `RuneClosure`) - fires on tap.
///   A missing/null value leaves the option visually enabled but inert,
///   matching Flutter's own API.
/// - `padding` ([EdgeInsets]?).
final class SimpleDialogOptionBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const SimpleDialogOptionBuilder();

  @override
  String get typeName => 'SimpleDialogOption';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return SimpleDialogOption(
      onPressed: voidEventCallback(args.named['onPressed'], ctx.events),
      padding: args.get<EdgeInsets>('padding'),
      child: args.get<Widget>('child'),
    );
  }
}
