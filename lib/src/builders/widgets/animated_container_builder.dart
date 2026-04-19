import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [AnimatedContainer]. Exposes the same slots as `Container`
/// plus a required `duration` and an optional `curve`.
///
/// When the host rebuilds the enclosing `RuneView` with new values for
/// any tweenable slot (`width`, `height`, `color`, `padding`, `margin`,
/// `decoration`, `alignment`), Flutter automatically animates from the
/// old to the new value over `duration` using `curve`. `curve` defaults
/// to [Curves.linear] when the source omits it.
final class AnimatedContainerBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const AnimatedContainerBuilder();

  @override
  String get typeName => 'AnimatedContainer';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return AnimatedContainer(
      duration: args.require<Duration>(
        'duration',
        source: 'AnimatedContainer',
      ),
      curve: args.getOr<Curve>('curve', Curves.linear),
      padding: args.get<EdgeInsetsGeometry>('padding'),
      margin: args.get<EdgeInsetsGeometry>('margin'),
      width: args.get<num>('width')?.toDouble(),
      height: args.get<num>('height')?.toDouble(),
      color: args.get<Color>('color'),
      decoration: args.get<Decoration>('decoration'),
      alignment: args.get<AlignmentGeometry>('alignment'),
      child: args.get<Widget>('child'),
    );
  }
}
