import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [AnimatedOpacity]. Fades its child in or out between the
/// previous and new `opacity` values each time the host rebuilds the
/// enclosing `RuneView`.
///
/// `opacity` and `duration` are required. `opacity` accepts any [num]
/// and is coerced to `double`. `curve` defaults to [Curves.linear].
final class AnimatedOpacityBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const AnimatedOpacityBuilder();

  @override
  String get typeName => 'AnimatedOpacity';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final opacity =
        args.require<num>('opacity', source: 'AnimatedOpacity').toDouble();
    return AnimatedOpacity(
      opacity: opacity,
      duration:
          args.require<Duration>('duration', source: 'AnimatedOpacity'),
      curve: args.getOr<Curve>('curve', Curves.linear),
      child: args.get<Widget>('child'),
    );
  }
}
