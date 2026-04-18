import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Icon] from a positional [IconData] (resolved via constants
/// registry, e.g. `Icons.home`) and optional `size` (num) and `color`.
final class IconBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const IconBuilder();

  @override
  String get typeName => 'Icon';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final data = args.requirePositional<IconData>(0, source: 'Icon');
    return Icon(
      data,
      size: args.get<num>('size')?.toDouble(),
      color: args.get<Color>('color'),
    );
  }
}
