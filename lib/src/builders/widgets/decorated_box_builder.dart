import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [DecoratedBox] — applies a [Decoration] to its child without
/// the padding/margin overhead of [Container].
///
/// Required `decoration`; optional `position` (a [DecorationPosition]
/// — defaults to `DecorationPosition.background`) and `child`.
final class DecoratedBoxBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const DecoratedBoxBuilder();

  @override
  String get typeName => 'DecoratedBox';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return DecoratedBox(
      decoration: args.require<Decoration>(
        'decoration',
        source: 'DecoratedBox',
      ),
      position: args.getOr<DecorationPosition>(
        'position',
        DecorationPosition.background,
      ),
      child: args.get<Widget>('child'),
    );
  }
}
