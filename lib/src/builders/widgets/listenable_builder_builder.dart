import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ListenableBuilder] (v1.12.0). A strict generalisation of
/// [AnimatedBuilder] that accepts any [Listenable] and rebuilds the
/// `builder` closure whenever the listenable notifies.
///
/// Source arguments:
/// - `listenable` (required, [Listenable]): any Flutter [Listenable]
///   (e.g. a `ValueNotifier`, `ChangeNotifier`, `AnimationController`)
///   whose changes should rebuild the subtree.
/// - `builder` (required, closure `(ctx, child) => Widget`).
/// - `child` (optional, [Widget]): forwarded as the second argument to
///   the builder closure. Hoisting a static subtree here avoids
///   rebuilding it on every notification.
final class ListenableBuilderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const ListenableBuilderBuilder();

  @override
  String get typeName => 'ListenableBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final listenable = args.named['listenable'];
    if (listenable == null) {
      throw const ArgumentException(
        'ListenableBuilder',
        'Missing required argument "listenable"',
      );
    }
    if (listenable is! Listenable) {
      throw ArgumentException(
        'ListenableBuilder',
        '`listenable` must be a Listenable (e.g. ChangeNotifier, '
        'ValueNotifier, AnimationController); got ${listenable.runtimeType}',
      );
    }
    final builder = toAnimatedBuilder(
      args.named['builder'],
      'ListenableBuilder',
    );
    return ListenableBuilder(
      listenable: listenable,
      builder: builder,
      child: args.get<Widget>('child'),
    );
  }
}
