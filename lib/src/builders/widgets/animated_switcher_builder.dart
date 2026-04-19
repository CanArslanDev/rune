import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [AnimatedSwitcher]. Fades between children when the child's
/// [Key] changes — pass a `Text('a', key: ValueKey('a'))` then a
/// `Text('b', key: ValueKey('b'))` across two source evaluations and
/// `AnimatedSwitcher` cross-fades between them over `duration`.
///
/// `duration` is required. Optional `reverseDuration`, `switchInCurve`,
/// `switchOutCurve` (both curves default to [Curves.linear]), `child`.
///
/// The closure-shaped `transitionBuilder` / `layoutBuilder` are out of
/// scope until function-literal support lands.
final class AnimatedSwitcherBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const AnimatedSwitcherBuilder();

  @override
  String get typeName => 'AnimatedSwitcher';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return AnimatedSwitcher(
      duration: args.require<Duration>(
        'duration',
        source: 'AnimatedSwitcher',
      ),
      reverseDuration: args.get<Duration>('reverseDuration'),
      switchInCurve: args.getOr<Curve>('switchInCurve', Curves.linear),
      switchOutCurve: args.getOr<Curve>('switchOutCurve', Curves.linear),
      child: args.get<Widget>('child'),
    );
  }
}
