import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [AnimatedCrossFade]. Cross-fades between two pre-declared
/// children driven by a [CrossFadeState] enum.
///
/// Required: `firstChild`, `secondChild`, `crossFadeState`, `duration`.
/// Optional: `reverseDuration`, `firstCurve` / `secondCurve` / `sizeCurve`
/// (all default to [Curves.linear]), and `alignment` (default
/// [Alignment.topCenter], matching Flutter's default).
///
/// `CrossFadeState.showFirst` / `.showSecond` are registered in the
/// default constants table so source can reference them directly.
///
/// The closure-shaped `layoutBuilder` is out of scope until
/// function-literal support lands.
final class AnimatedCrossFadeBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const AnimatedCrossFadeBuilder();

  @override
  String get typeName => 'AnimatedCrossFade';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return AnimatedCrossFade(
      firstChild: args.require<Widget>(
        'firstChild',
        source: 'AnimatedCrossFade',
      ),
      secondChild: args.require<Widget>(
        'secondChild',
        source: 'AnimatedCrossFade',
      ),
      crossFadeState: args.require<CrossFadeState>(
        'crossFadeState',
        source: 'AnimatedCrossFade',
      ),
      duration: args.require<Duration>(
        'duration',
        source: 'AnimatedCrossFade',
      ),
      reverseDuration: args.get<Duration>('reverseDuration'),
      firstCurve: args.getOr<Curve>('firstCurve', Curves.linear),
      secondCurve: args.getOr<Curve>('secondCurve', Curves.linear),
      sizeCurve: args.getOr<Curve>('sizeCurve', Curves.linear),
      alignment: args.getOr<AlignmentGeometry>(
        'alignment',
        Alignment.topCenter,
      ),
    );
  }
}
