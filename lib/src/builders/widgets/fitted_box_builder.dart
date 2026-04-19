import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [FittedBox] — scales and positions its optional `child` within
/// itself according to `fit` (defaults to `BoxFit.contain`) and
/// `alignment` (defaults to `Alignment.center`).
final class FittedBoxBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const FittedBoxBuilder();

  @override
  String get typeName => 'FittedBox';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return FittedBox(
      fit: args.getOr<BoxFit>('fit', BoxFit.contain),
      alignment: args.getOr<AlignmentGeometry>(
        'alignment',
        Alignment.center,
      ),
      child: args.get<Widget>('child'),
    );
  }
}
