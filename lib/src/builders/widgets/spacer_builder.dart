import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Spacer] — fills empty space along a Flex parent's main axis.
/// Optional `flex` (default 1) controls proportional distribution.
final class SpacerBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SpacerBuilder();

  @override
  String get typeName => 'Spacer';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Spacer(flex: args.getOr<int>('flex', 1));
  }
}
