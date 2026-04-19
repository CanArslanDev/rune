import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [ListTile]. Typical slots (`title`, `subtitle`,
/// `leading`, `trailing`) accept Widget values; `onTap` accepts a
/// `String` event name that, when tapped, dispatches through
/// [RuneContext.events] with empty args. Boolean flags (`dense`,
/// `enabled`, `selected`) plumb through directly; leaving them out
/// gives Flutter's own defaults.
final class ListTileBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ListTileBuilder();

  @override
  String get typeName => 'ListTile';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return ListTile(
      title: args.get<Widget>('title'),
      subtitle: args.get<Widget>('subtitle'),
      leading: args.get<Widget>('leading'),
      trailing: args.get<Widget>('trailing'),
      onTap: voidEventCallback(args.get<String>('onTap'), ctx.events),
      dense: args.get<bool>('dense'),
      enabled: args.getOr<bool>('enabled', true),
      selected: args.getOr<bool>('selected', false),
    );
  }
}
