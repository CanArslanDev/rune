import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Container]. Phase 1 wires up the full attribute set for
/// forward-compat; values that require Phase-2 value builders (colors,
/// alignments, decorations) are simply absent from resolved arguments
/// until those builders land.
final class ContainerBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ContainerBuilder();

  @override
  String get typeName => 'Container';

  /// Builds a [Container]. All arguments are optional. `width` and `height`
  /// accept any [num] value and are converted to [double]. `color`,
  /// `alignment`, and `decoration` are wired for Phase 2.
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Container(
      padding: args.get<EdgeInsetsGeometry>('padding'),
      margin: args.get<EdgeInsetsGeometry>('margin'),
      width: args.get<num>('width')?.toDouble(),
      height: args.get<num>('height')?.toDouble(),
      color: args.get<Color>('color'),
      decoration: args.get<Decoration>('decoration'),
      alignment: args.get<AlignmentGeometry>('alignment'),
      child: args.get<Widget>('child'),
    );
  }
}
