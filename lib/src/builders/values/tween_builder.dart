import 'package:flutter/animation.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [Tween] with untyped `Object?` begin/end slots.
///
/// Rune source has no generic-type syntax, so the returned tween is a
/// `Tween<Object?>` whose `lerp(t)` relies on the underlying Dart
/// addition/multiplication operators. Typical usage: numeric ranges
/// (`Tween(begin: 0.0, end: 1.0)`) or [Offset] ranges
/// (`Tween(begin: Offset(0, 1), end: Offset(0, 0))`) where the value
/// type supports `operator +`, `operator -`, and scalar multiplication.
///
/// For colors use the dedicated `ColorTween` value builder instead.
final class TweenBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const TweenBuilder();

  @override
  String get typeName => 'Tween';

  @override
  String? get constructorName => null;

  @override
  Tween<Object?> build(ResolvedArguments args, RuneContext ctx) {
    return Tween<Object?>(
      begin: args.get<Object>('begin'),
      end: args.get<Object>('end'),
    );
  }
}
