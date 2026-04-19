import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [ConstrainedBox] — applies additional [BoxConstraints] on top
/// of the constraints the parent passes to its optional `child`.
///
/// The `constraints` named argument is required and must resolve to a
/// [BoxConstraints] value (typically via the `BoxConstraints(...)`
/// value builder). Missing or null `constraints` raises
/// `ArgumentException`.
final class ConstrainedBoxBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ConstrainedBoxBuilder();

  @override
  String get typeName => 'ConstrainedBox';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return ConstrainedBox(
      constraints: args.require<BoxConstraints>(
        'constraints',
        source: 'ConstrainedBox',
      ),
      child: args.get<Widget>('child'),
    );
  }
}
