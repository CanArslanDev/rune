import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ListView] (default-constructor, static children) from
/// optional `children`, `scrollDirection`, `reverse`, `shrinkWrap`,
/// `padding`, and `controller`. `.builder` / `.separated` constructors
/// are out of scope for Phase 2c.
///
/// The optional `controller` ([ScrollController]) accepts an externally-
/// owned controller, typically constructed inside a `StatefulBuilder`'s
/// `initial` map so the source can drive scroll position via
/// `state.ctrl.jumpTo(...)` / `animateTo`. Disposal stays with the
/// source-level owner.
final class ListViewBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const ListViewBuilder();

  @override
  String get typeName => 'ListView';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final children = (args.get<List<Object?>>('children') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    return ListView(
      scrollDirection: args.getOr<Axis>('scrollDirection', Axis.vertical),
      reverse: args.getOr<bool>('reverse', false),
      shrinkWrap: args.getOr<bool>('shrinkWrap', false),
      padding: args.get<EdgeInsetsGeometry>('padding'),
      controller: args.get<ScrollController>('controller'),
      children: children,
    );
  }
}
