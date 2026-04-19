import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Transform.flip(...)` — flips its optional `child` along one or
/// both axes. `flipX` and `flipY` both default to `false` (identity).
/// `transformHitTests` defaults to `true` (Flutter's own default).
/// Alignment is fixed to [Alignment.center] by Flutter's
/// [Transform.flip] constructor and cannot be overridden from source.
///
/// Registered as a [RuneValueBuilder] because `Transform.flip` is a
/// named constructor; the dispatcher routes `Transform.flip(...)`
/// invocations to this builder when no plain `Transform` widget builder
/// is registered. It still returns a [Widget].
final class TransformFlipBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const TransformFlipBuilder();

  @override
  String get typeName => 'Transform';

  @override
  String? get constructorName => 'flip';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Transform.flip(
      flipX: args.getOr<bool>('flipX', false),
      flipY: args.getOr<bool>('flipY', false),
      transformHitTests: args.getOr<bool>('transformHitTests', true),
      child: args.get<Widget>('child'),
    );
  }
}
