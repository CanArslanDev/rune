import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Padding] from a required `padding` ([EdgeInsetsGeometry]) and
/// an optional `child` widget.
final class PaddingBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const PaddingBuilder();

  @override
  String get typeName => 'Padding';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final padding =
        args.require<EdgeInsetsGeometry>('padding', source: 'Padding');
    return Padding(
      padding: padding,
      child: args.get<Widget>('child'),
    );
  }
}
