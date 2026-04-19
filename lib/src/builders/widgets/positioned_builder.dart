import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Positioned]. Places a required `child` at specific coordinates
/// inside a [Stack].
///
/// Supported arguments: `left`, `top`, `right`, `bottom`, `width`,
/// `height` (all optional nums coerced to double), and `child` (required
/// [Widget]). Flutter's own runtime assertions apply when incompatible
/// combinations are provided (e.g. left + right + width). Named
/// constructors such as `Positioned.fromRect`, `Positioned.fill`, and
/// `Positioned.directional` are out of scope.
final class PositionedBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const PositionedBuilder();

  @override
  String get typeName => 'Positioned';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final child = args.require<Widget>('child', source: 'Positioned');
    return Positioned(
      left: args.get<num>('left')?.toDouble(),
      top: args.get<num>('top')?.toDouble(),
      right: args.get<num>('right')?.toDouble(),
      bottom: args.get<num>('bottom')?.toDouble(),
      width: args.get<num>('width')?.toDouble(),
      height: args.get<num>('height')?.toDouble(),
      child: child,
    );
  }
}
