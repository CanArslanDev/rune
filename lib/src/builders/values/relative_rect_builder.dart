import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [RelativeRect] via the `fromLTRB` named constructor
/// (v1.12.0). Primary consumer is the `showMenu(position: ..., ...)`
/// imperative bridge, where source computes a menu anchor from absolute
/// coordinates.
///
/// Source arguments (all required, positional `num`s coerced to
/// `double`): `left`, `top`, `right`, `bottom`.
final class RelativeRectFromLTRBBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const RelativeRectFromLTRBBuilder();

  @override
  String get typeName => 'RelativeRect';

  @override
  String? get constructorName => 'fromLTRB';

  @override
  RelativeRect build(ResolvedArguments args, RuneContext ctx) {
    final left =
        args.requirePositional<num>(0, source: 'RelativeRect.fromLTRB');
    final top =
        args.requirePositional<num>(1, source: 'RelativeRect.fromLTRB');
    final right =
        args.requirePositional<num>(2, source: 'RelativeRect.fromLTRB');
    final bottom =
        args.requirePositional<num>(3, source: 'RelativeRect.fromLTRB');
    return RelativeRect.fromLTRB(
      left.toDouble(),
      top.toDouble(),
      right.toDouble(),
      bottom.toDouble(),
    );
  }
}
