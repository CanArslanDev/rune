import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ListView] (default-constructor, static children) from
/// optional `children`, `scrollDirection`, `reverse`, `shrinkWrap`, and
/// `padding`. `.builder` / `.separated` constructors are out of scope for
/// Phase 2c.
final class ListViewBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
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
      children: children,
    );
  }
}
