import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Flexible] from a required `child`, optional `flex` (default 1),
/// and optional `fit` ([FlexFit], default `FlexFit.loose`).
final class FlexibleBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const FlexibleBuilder();

  @override
  String get typeName => 'Flexible';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final child = args.require<Widget>('child', source: 'Flexible');
    return Flexible(
      flex: args.get<int>('flex') ?? 1,
      fit: args.getOr<FlexFit>('fit', FlexFit.loose),
      child: child,
    );
  }
}
