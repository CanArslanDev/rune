import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [LimitedBox] — caps its optional `child` only when the parent
/// offers unbounded constraints along the matching axis.
///
/// Optional `maxWidth` and `maxHeight` nums (coerced to double) default
/// to `double.infinity`, which is also Flutter's own default. Pass
/// either edge to impose a ceiling that only activates under infinite
/// parent constraints (typical inside unbounded scroll views).
final class LimitedBoxBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const LimitedBoxBuilder();

  @override
  String get typeName => 'LimitedBox';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return LimitedBox(
      maxWidth: args.get<num>('maxWidth')?.toDouble() ?? double.infinity,
      maxHeight: args.get<num>('maxHeight')?.toDouble() ?? double.infinity,
      child: args.get<Widget>('child'),
    );
  }
}
