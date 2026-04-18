import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Center] with optional `heightFactor`, `widthFactor`, and `child`.
final class CenterBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const CenterBuilder();

  @override
  String get typeName => 'Center';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Center(
      heightFactor: args.get<num>('heightFactor')?.toDouble(),
      widthFactor: args.get<num>('widthFactor')?.toDouble(),
      child: args.get<Widget>('child'),
    );
  }
}
