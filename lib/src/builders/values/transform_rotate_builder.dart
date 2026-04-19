import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Transform.rotate(...)` — applies a rotation (in radians) to
/// its optional `child`. Required `angle: num`; optional `alignment`
/// defaults to `Alignment.center`.
///
/// Registered as a [RuneValueBuilder] because `Transform.rotate` is a
/// named constructor; the dispatcher routes `Transform.rotate(...)`
/// invocations to this builder when no plain `Transform` widget builder
/// is registered. It still returns a [Widget].
final class TransformRotateBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const TransformRotateBuilder();

  @override
  String get typeName => 'Transform';

  @override
  String? get constructorName => 'rotate';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Transform.rotate(
      angle:
          args.require<num>('angle', source: 'Transform.rotate').toDouble(),
      alignment: args.getOr<AlignmentGeometry>(
        'alignment',
        Alignment.center,
      ),
      child: args.get<Widget>('child'),
    );
  }
}
