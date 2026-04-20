import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Step] — one step in a [Stepper]. Required `title` (Widget)
/// and `content` (Widget). Optional `subtitle` (Widget), `isActive`
/// (bool, default `false`), and `state` ([StepState], default
/// [StepState.indexed]).
final class StepBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const StepBuilder();

  @override
  String get typeName => 'Step';

  @override
  String? get constructorName => null;

  @override
  Step build(ResolvedArguments args, RuneContext ctx) {
    return Step(
      title: args.require<Widget>('title', source: 'Step'),
      content: args.require<Widget>('content', source: 'Step'),
      subtitle: args.get<Widget>('subtitle'),
      isActive: args.getOr<bool>('isActive', false),
      state: args.getOr<StepState>('state', StepState.indexed),
    );
  }
}
