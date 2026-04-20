import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [AnimatedBuilder]. Rebuilds the `builder` closure every time
/// `animation` ticks, wrapping a pre-built static `child` for free
/// memoization.
///
/// Source arguments:
/// - `animation` (required, [Listenable]): the animation or any
///   [Listenable] whose changes should rebuild the subtree. An
///   `AnimationController` is a valid [Listenable].
/// - `builder` (required, closure `(ctx, child) => Widget`).
/// - `child` (optional, [Widget]): forwarded as the second argument to
///   the builder closure. Hoisting a static subtree here avoids
///   rebuilding it on every tick.
final class AnimatedBuilderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const AnimatedBuilderBuilder();

  @override
  String get typeName => 'AnimatedBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final animation = args.named['animation'];
    if (animation == null) {
      throw const ArgumentException(
        'AnimatedBuilder',
        'Missing required argument "animation"',
      );
    }
    if (animation is! Listenable) {
      throw ArgumentException(
        'AnimatedBuilder',
        '`animation` must be a Listenable (e.g. AnimationController, '
        'CurvedAnimation); got ${animation.runtimeType}',
      );
    }
    final builder = toAnimatedBuilder(
      args.named['builder'],
      'AnimatedBuilder',
    );
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: args.get<Widget>('child'),
    );
  }
}
