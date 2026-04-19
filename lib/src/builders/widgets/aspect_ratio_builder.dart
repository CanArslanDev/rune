import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [AspectRatio]. Forces `child` to a specific width-to-height
/// ratio derived from the required `aspectRatio` named argument (num,
/// coerced to double). An absent or null `aspectRatio` raises
/// `ArgumentException`.
final class AspectRatioBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const AspectRatioBuilder();

  @override
  String get typeName => 'AspectRatio';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final ratio = args.require<num>('aspectRatio', source: 'AspectRatio');
    return AspectRatio(
      aspectRatio: ratio.toDouble(),
      child: args.get<Widget>('child'),
    );
  }
}
