import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ClipOval] — clips its optional `child` to an oval (or a
/// circle when the child is square). `clipBehavior` ([Clip]; defaults
/// to [Clip.antiAlias]) controls the edge-blending style.
final class ClipOvalBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ClipOvalBuilder();

  @override
  String get typeName => 'ClipOval';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return ClipOval(
      clipBehavior: args.getOr<Clip>('clipBehavior', Clip.antiAlias),
      child: args.get<Widget>('child'),
    );
  }
}
