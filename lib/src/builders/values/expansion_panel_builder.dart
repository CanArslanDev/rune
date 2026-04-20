import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ExpansionPanel] — one panel in an [ExpansionPanelList].
/// Required `headerBuilder` (`(BuildContext, bool isExpanded) -> Widget`
/// closure) and `body` (Widget). Optional `isExpanded` (bool, default
/// `false`) and `canTapOnHeader` (bool, default `false`).
///
/// `headerBuilder` accepts a closure only (no String event-name path):
/// it returns a Widget, so it cannot be modelled as a void event.
/// Missing `headerBuilder` raises an `ArgumentException`.
final class ExpansionPanelBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const ExpansionPanelBuilder();

  @override
  String get typeName => 'ExpansionPanel';

  @override
  String? get constructorName => null;

  @override
  ExpansionPanel build(ResolvedArguments args, RuneContext ctx) {
    final body = args.require<Widget>('body', source: 'ExpansionPanel');
    final headerBuilder = toExpansionPanelHeaderBuilder(
      args.named['headerBuilder'],
      'ExpansionPanel',
    );
    return ExpansionPanel(
      headerBuilder: headerBuilder,
      body: body,
      isExpanded: args.getOr<bool>('isExpanded', false),
      canTapOnHeader: args.getOr<bool>('canTapOnHeader', false),
    );
  }
}
