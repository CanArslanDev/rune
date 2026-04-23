import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Border.symmetric(vertical, horizontal)` where either side can
/// be omitted. Omitted sides default to [BorderSide.none].
///
/// Use with `BoxDecoration.border:` when the left/right pair should
/// match and the top/bottom pair should match.
final class BorderSymmetricBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const BorderSymmetricBuilder();

  @override
  String get typeName => 'Border';

  @override
  String? get constructorName => 'symmetric';

  @override
  Border build(ResolvedArguments args, RuneContext ctx) {
    return Border.symmetric(
      vertical: args.get<BorderSide>('vertical') ?? BorderSide.none,
      horizontal: args.get<BorderSide>('horizontal') ?? BorderSide.none,
    );
  }
}
