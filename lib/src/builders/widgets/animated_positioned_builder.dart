import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [AnimatedPositioned]. The animated sibling of `Positioned` —
/// must live inside a [Stack] ancestor at render time.
///
/// `duration` and `child` are required. When the host rebuilds the
/// enclosing `RuneView` with new values for any positional slot
/// (`left`, `top`, `right`, `bottom`, `width`, `height`), Flutter
/// animates from the old to the new value over `duration` using
/// `curve` (defaulting to [Curves.linear]).
final class AnimatedPositionedBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const AnimatedPositionedBuilder();

  @override
  String get typeName => 'AnimatedPositioned';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final child = args.require<Widget>('child', source: 'AnimatedPositioned');
    return AnimatedPositioned(
      duration:
          args.require<Duration>('duration', source: 'AnimatedPositioned'),
      curve: args.getOr<Curve>('curve', Curves.linear),
      left: args.get<num>('left')?.toDouble(),
      top: args.get<num>('top')?.toDouble(),
      right: args.get<num>('right')?.toDouble(),
      bottom: args.get<num>('bottom')?.toDouble(),
      width: args.get<num>('width')?.toDouble(),
      height: args.get<num>('height')?.toDouble(),
      child: child,
    );
  }
}
