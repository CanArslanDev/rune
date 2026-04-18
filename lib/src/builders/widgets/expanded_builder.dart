import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Expanded] from a required `child` and an optional `flex` (int,
/// default 1).
final class ExpandedBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ExpandedBuilder();

  @override
  String get typeName => 'Expanded';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final child = args.require<Widget>('child', source: 'Expanded');
    return Expanded(
      flex: args.get<int>('flex') ?? 1,
      child: child,
    );
  }
}
