import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [FractionallySizedBox] — sizes its optional `child` to a
/// fraction of the incoming parent constraints.
///
/// Optional nullable `widthFactor` / `heightFactor` nums (coerced to
/// double); a null factor means that axis is not constrained by the
/// parent, matching Flutter's own semantics. Optional `alignment`
/// defaults to `Alignment.center`.
final class FractionallySizedBoxBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const FractionallySizedBoxBuilder();

  @override
  String get typeName => 'FractionallySizedBox';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return FractionallySizedBox(
      widthFactor: args.get<num>('widthFactor')?.toDouble(),
      heightFactor: args.get<num>('heightFactor')?.toDouble(),
      alignment: args.getOr<AlignmentGeometry>(
        'alignment',
        Alignment.center,
      ),
      child: args.get<Widget>('child'),
    );
  }
}
