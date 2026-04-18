import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SizedBox] with optional `width`, `height`, and `child`.
final class SizedBoxBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SizedBoxBuilder();

  @override
  String get typeName => 'SizedBox';

  /// Builds a [SizedBox]. All arguments are optional. `width` and `height`
  /// accept any [num] value and are converted to [double].
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return SizedBox(
      width: args.get<num>('width')?.toDouble(),
      height: args.get<num>('height')?.toDouble(),
      child: args.get<Widget>('child'),
    );
  }
}
