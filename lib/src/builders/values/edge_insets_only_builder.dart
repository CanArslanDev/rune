import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `EdgeInsets.only(left:, top:, right:, bottom:)` from any subset
/// of numeric named arguments. Missing sides default to `0`.
final class EdgeInsetsOnlyBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const EdgeInsetsOnlyBuilder();

  @override
  String get typeName => 'EdgeInsets';

  @override
  String? get constructorName => 'only';

  /// Builds an [EdgeInsets.only] from any combination of `left`, `top`,
  /// `right`, and `bottom` named arguments. Each defaults to `0.0` when
  /// absent.
  @override
  EdgeInsets build(ResolvedArguments args, RuneContext ctx) {
    return EdgeInsets.only(
      left: args.get<num>('left')?.toDouble() ?? 0.0,
      top: args.get<num>('top')?.toDouble() ?? 0.0,
      right: args.get<num>('right')?.toDouble() ?? 0.0,
      bottom: args.get<num>('bottom')?.toDouble() ?? 0.0,
    );
  }
}
