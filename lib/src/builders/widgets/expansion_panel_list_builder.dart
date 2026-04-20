import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ExpansionPanelList] — a Material list of
/// [ExpansionPanel]s. Required `children` (`List<ExpansionPanel>`;
/// non-[ExpansionPanel] entries silently filtered). Optional:
/// `expansionCallback` (`(int panelIndex, bool isExpanded) -> void`
/// closure; fires when the user taps a panel header),
/// `animationDuration` (Duration), `expandedHeaderPadding`
/// ([EdgeInsets]).
///
/// Flutter rejects non-[ExpansionPanel] entries via a runtime cast;
/// filtering at the builder level surfaces a cleaner error if source
/// mixes types in the list.
final class ExpansionPanelListBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const ExpansionPanelListBuilder();

  @override
  String get typeName => 'ExpansionPanelList';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final childrenRaw = args.get<List<Object?>>('children');
    if (childrenRaw == null) {
      throw const ArgumentException(
        'ExpansionPanelList',
        'Missing required argument "children"',
      );
    }
    final children =
        childrenRaw.whereType<ExpansionPanel>().toList(growable: false);
    return ExpansionPanelList(
      expansionCallback: toIntBoolCallback(
        args.named['expansionCallback'],
        'ExpansionPanelList',
        paramName: 'expansionCallback',
      ),
      animationDuration: args.getOr<Duration>(
        'animationDuration',
        kThemeAnimationDuration,
      ),
      expandedHeaderPadding: args.getOr<EdgeInsets>(
        'expandedHeaderPadding',
        const EdgeInsets.symmetric(vertical: 16),
      ),
      children: children,
    );
  }
}
