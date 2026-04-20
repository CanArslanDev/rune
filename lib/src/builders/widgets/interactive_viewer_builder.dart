import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [InteractiveViewer]. Pan/zoom wrapper around a single
/// child. Exposes the subset of arguments relevant to source-driven
/// UIs: `child`, `minScale`, `maxScale`, `panEnabled`, `scaleEnabled`,
/// and `boundaryMargin`. More exotic controls (the transformation
/// controller, pan-axis restrictions, interaction hooks) are deferred
/// until a concrete use case surfaces.
///
/// Defaults match Flutter: `minScale: 0.8`, `maxScale: 2.5`,
/// `panEnabled: true`, `scaleEnabled: true`. `boundaryMargin` defaults
/// to [EdgeInsets.zero] when omitted.
final class InteractiveViewerBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const InteractiveViewerBuilder();

  @override
  String get typeName => 'InteractiveViewer';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final minScale = args.get<num>('minScale')?.toDouble() ?? 0.8;
    final maxScale = args.get<num>('maxScale')?.toDouble() ?? 2.5;
    return InteractiveViewer(
      minScale: minScale,
      maxScale: maxScale,
      panEnabled: args.getOr<bool>('panEnabled', true),
      scaleEnabled: args.getOr<bool>('scaleEnabled', true),
      boundaryMargin: args.getOr<EdgeInsets>(
        'boundaryMargin',
        EdgeInsets.zero,
      ),
      child: args.require<Widget>('child', source: 'InteractiveViewer'),
    );
  }
}
