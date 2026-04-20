import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [RotationTransition]. Drives child rotation from an
/// [Animation] of `double`, where `1.0` is a full 360-degree turn.
///
/// Source arguments:
/// - `turns` (required, `Animation<double>`).
/// - `child` (optional, [Widget]).
/// - `alignment` (optional, [Alignment]): defaults to
///   [Alignment.center].
/// - `filterQuality` (optional, [FilterQuality]).
final class RotationTransitionBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const RotationTransitionBuilder();

  @override
  String get typeName => 'RotationTransition';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return RotationTransition(
      turns: args.require<Animation<double>>(
        'turns',
        source: 'RotationTransition',
      ),
      alignment: args.getOr<Alignment>('alignment', Alignment.center),
      filterQuality: args.get<FilterQuality>('filterQuality'),
      child: args.get<Widget>('child'),
    );
  }
}
