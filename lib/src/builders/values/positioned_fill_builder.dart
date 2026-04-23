import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Positioned.fill(child: ...)` inside a [Stack]. All four sides
/// default to `0` so the child stretches to fill the stack. Override any
/// individual side by passing `left:` / `top:` / `right:` / `bottom:`;
/// omitted sides are forwarded as `0`, matching Flutter's default.
///
/// Rune's value-registry dispatch routes `Positioned.fill(...)` to this
/// builder, mirroring how `Transform.scale` / `Transform.rotate` layer
/// named-constructor variants on top of a default-constructor
/// `PositionedBuilder` without clobbering it.
///
/// Required named arg: `child` ([Widget]).
final class PositionedFillBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const PositionedFillBuilder();

  @override
  String get typeName => 'Positioned';

  @override
  String? get constructorName => 'fill';

  @override
  Positioned build(ResolvedArguments args, RuneContext ctx) {
    final child = args.require<Widget>('child', source: 'Positioned.fill');
    return Positioned.fill(
      left: args.get<num>('left')?.toDouble() ?? 0,
      top: args.get<num>('top')?.toDouble() ?? 0,
      right: args.get<num>('right')?.toDouble() ?? 0,
      bottom: args.get<num>('bottom')?.toDouble() ?? 0,
      child: child,
    );
  }
}
