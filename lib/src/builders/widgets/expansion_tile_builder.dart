import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ExpansionTile] — a Material list tile that reveals a
/// collapsible list of children. Required `title` (Widget). Optional:
/// `children` (list of widgets; non-Widget entries filtered),
/// `subtitle`, `leading`, `trailing` (Widgets), `initiallyExpanded`
/// (bool, default `false`), `onExpansionChanged` (String event name or
/// `(bool) -> void` closure; the new expansion state is forwarded),
/// `backgroundColor`, `collapsedBackgroundColor`, `iconColor`,
/// `textColor` ([Color]s), `tilePadding`, `childrenPadding`
/// ([EdgeInsetsGeometry]s).
final class ExpansionTileBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const ExpansionTileBuilder();

  @override
  String get typeName => 'ExpansionTile';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final title = args.require<Widget>('title', source: 'ExpansionTile');
    final children =
        (args.get<List<Object?>>('children') ?? const <Object?>[])
            .whereType<Widget>()
            .toList(growable: false);
    return ExpansionTile(
      title: title,
      subtitle: args.get<Widget>('subtitle'),
      leading: args.get<Widget>('leading'),
      trailing: args.get<Widget>('trailing'),
      initiallyExpanded: args.getOr<bool>('initiallyExpanded', false),
      onExpansionChanged: valueEventCallback<bool>(
        args.named['onExpansionChanged'],
        ctx.events,
      ),
      backgroundColor: args.get<Color>('backgroundColor'),
      collapsedBackgroundColor: args.get<Color>('collapsedBackgroundColor'),
      iconColor: args.get<Color>('iconColor'),
      textColor: args.get<Color>('textColor'),
      tilePadding: args.get<EdgeInsetsGeometry>('tilePadding'),
      childrenPadding: args.get<EdgeInsetsGeometry>('childrenPadding'),
      children: children,
    );
  }
}
