import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ReorderableListView]. A Material list that lets the user
/// drag items into a new order. Every child widget MUST carry a
/// non-null [Key] (Flutter asserts this at construction time); source
/// should attach `key: ValueKey(...)` to each entry.
///
/// Required: `children` (list of keyed widgets), `onReorder`
/// (`(oldIndex, newIndex) -> void` closure). Optional: `padding`,
/// `scrollDirection` (defaults to [Axis.vertical]).
///
/// `onReorder` is a 2-arg closure; Flutter invokes it after the drag
/// completes. The source body is responsible for mutating whatever
/// state owns the list order (typically
/// `state.set('items', moved(...))` inside a [StatefulBuilder]).
final class ReorderableListViewBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const ReorderableListViewBuilder();

  @override
  String get typeName => 'ReorderableListView';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final children = (args.get<List<Object?>>('children') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    final onReorder = toReorderCallback(
      args.named['onReorder'],
      'ReorderableListView',
    );
    return ReorderableListView(
      onReorder: onReorder,
      padding: args.get<EdgeInsets>('padding'),
      scrollDirection: args.getOr<Axis>('scrollDirection', Axis.vertical),
      children: children,
    );
  }
}
