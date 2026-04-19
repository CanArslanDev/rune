import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [AnimatedSize]. Animates the widget's own size whenever its
/// child's intrinsic size changes.
///
/// `duration` is required. Optional `reverseDuration`, `curve`
/// (default [Curves.linear]), `alignment` (default [Alignment.center],
/// matching Flutter's default), and `child`.
final class AnimatedSizeBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const AnimatedSizeBuilder();

  @override
  String get typeName => 'AnimatedSize';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return AnimatedSize(
      duration: args.require<Duration>(
        'duration',
        source: 'AnimatedSize',
      ),
      reverseDuration: args.get<Duration>('reverseDuration'),
      curve: args.getOr<Curve>('curve', Curves.linear),
      alignment: args.getOr<AlignmentGeometry>(
        'alignment',
        Alignment.center,
      ),
      child: args.get<Widget>('child'),
    );
  }
}
