import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SizeTransition]. Drives child sizing along an axis from an
/// [Animation] of `double`.
///
/// Source arguments:
/// - `sizeFactor` (required, `Animation<double>`).
/// - `child` (optional, [Widget]).
/// - `axis` (optional, [Axis]): defaults to [Axis.vertical].
/// - `axisAlignment` (optional, `num`): defaults to `0.0` (center).
final class SizeTransitionBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const SizeTransitionBuilder();

  @override
  String get typeName => 'SizeTransition';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return SizeTransition(
      sizeFactor: args.require<Animation<double>>(
        'sizeFactor',
        source: 'SizeTransition',
      ),
      axis: args.getOr<Axis>('axis', Axis.vertical),
      axisAlignment: args.get<num>('axisAlignment')?.toDouble() ?? 0.0,
      child: args.get<Widget>('child'),
    );
  }
}
