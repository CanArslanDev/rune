import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Transform.translate(...)` — shifts its optional `child` by a
/// required [Offset] without affecting layout. Optional
/// `transformHitTests` defaults to `true` (Flutter's own default).
///
/// Registered as a [RuneValueBuilder] because `Transform.translate` is a
/// named constructor; the dispatcher routes `Transform.translate(...)`
/// invocations to this builder when no plain `Transform` widget builder
/// is registered. It still returns a [Widget].
final class TransformTranslateBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const TransformTranslateBuilder();

  @override
  String get typeName => 'Transform';

  @override
  String? get constructorName => 'translate';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Transform.translate(
      offset: args.require<Offset>('offset', source: 'Transform.translate'),
      transformHitTests: args.getOr<bool>('transformHitTests', true),
      child: args.get<Widget>('child'),
    );
  }
}
