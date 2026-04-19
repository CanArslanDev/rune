import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [UnconstrainedBox] — discards the parent's constraints along
/// one axis or both, letting its optional `child` size itself freely.
///
/// Optional `constrainedAxis` (`Axis?`, null means both axes are
/// unconstrained), `alignment` (defaults to `Alignment.center`), and
/// `clipBehavior` (defaults to `Clip.none`). `textDirection` is not
/// exposed here; consumers that need it can register a custom builder.
final class UnconstrainedBoxBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const UnconstrainedBoxBuilder();

  @override
  String get typeName => 'UnconstrainedBox';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return UnconstrainedBox(
      alignment: args.getOr<AlignmentGeometry>(
        'alignment',
        Alignment.center,
      ),
      constrainedAxis: args.get<Axis>('constrainedAxis'),
      clipBehavior: args.getOr<Clip>('clipBehavior', Clip.none),
      child: args.get<Widget>('child'),
    );
  }
}
