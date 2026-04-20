import 'package:flutter/animation.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [CurvedAnimation] that wraps a parent [Animation] through a
/// [Curve].
///
/// Source arguments:
/// - `parent` (required, [Animation]): the driving animation, typically
///   an `AnimationController`.
/// - `curve` (required, [Curve]): forward-direction curve; `Curves.*`
///   constants are pre-registered via Rune's default constants.
/// - `reverseCurve` (optional, [Curve]): reverse-direction curve.
final class CurvedAnimationBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const CurvedAnimationBuilder();

  @override
  String get typeName => 'CurvedAnimation';

  @override
  String? get constructorName => null;

  @override
  CurvedAnimation build(ResolvedArguments args, RuneContext ctx) {
    return CurvedAnimation(
      parent: args.require<Animation<double>>(
        'parent',
        source: 'CurvedAnimation',
      ),
      curve: args.require<Curve>('curve', source: 'CurvedAnimation'),
      reverseCurve: args.get<Curve>('reverseCurve'),
    );
  }
}
