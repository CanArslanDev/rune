import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ScaleTransition]. Drives child scale from an [Animation] of
/// `double`.
///
/// Source arguments:
/// - `scale` (required, `Animation<double>`).
/// - `child` (optional, [Widget]).
/// - `alignment` (optional, [Alignment]): defaults to
///   [Alignment.center].
/// - `filterQuality` (optional, [FilterQuality]).
final class ScaleTransitionBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const ScaleTransitionBuilder();

  @override
  String get typeName => 'ScaleTransition';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return ScaleTransition(
      scale: args.require<Animation<double>>(
        'scale',
        source: 'ScaleTransition',
      ),
      alignment: args.getOr<Alignment>('alignment', Alignment.center),
      filterQuality: args.get<FilterQuality>('filterQuality'),
      child: args.get<Widget>('child'),
    );
  }
}
