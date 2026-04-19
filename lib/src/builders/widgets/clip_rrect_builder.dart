import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ClipRRect] — rounds its optional `child`'s corners by
/// `borderRadius` ([BorderRadiusGeometry]; defaults to
/// [BorderRadius.zero]). `clipBehavior` ([Clip]; defaults to
/// [Clip.antiAlias]) controls the edge-blending style.
final class ClipRRectBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ClipRRectBuilder();

  @override
  String get typeName => 'ClipRRect';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return ClipRRect(
      borderRadius: args.getOr<BorderRadiusGeometry>(
        'borderRadius',
        BorderRadius.zero,
      ),
      clipBehavior: args.getOr<Clip>('clipBehavior', Clip.antiAlias),
      child: args.get<Widget>('child'),
    );
  }
}
