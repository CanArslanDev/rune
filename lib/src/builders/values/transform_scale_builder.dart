import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Transform.scale(...)` — applies a scale transform to its
/// optional `child`. Callers provide either a single uniform `scale`
/// OR axis-specific `scaleX` / `scaleY`; Flutter's own assertion
/// enforces the XOR (we don't pre-validate here so the diagnostic
/// originates from Flutter itself). Optional `alignment` defaults to
/// `Alignment.center`.
///
/// Registered as a [RuneValueBuilder] because `Transform.scale` is a
/// named constructor; the dispatcher routes `Transform.scale(...)`
/// invocations to this builder when no plain `Transform` widget builder
/// is registered. It still returns a [Widget].
final class TransformScaleBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const TransformScaleBuilder();

  @override
  String get typeName => 'Transform';

  @override
  String? get constructorName => 'scale';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final scale = args.get<num>('scale')?.toDouble();
    final scaleX = args.get<num>('scaleX')?.toDouble();
    final scaleY = args.get<num>('scaleY')?.toDouble();
    return Transform.scale(
      scale: scale,
      scaleX: scaleX,
      scaleY: scaleY,
      alignment: args.getOr<AlignmentGeometry>(
        'alignment',
        Alignment.center,
      ),
      child: args.get<Widget>('child'),
    );
  }
}
