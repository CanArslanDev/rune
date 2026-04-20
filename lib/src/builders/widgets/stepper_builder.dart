import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Stepper] — a Material horizontal or vertical step-by-step
/// progress indicator. Required `steps` (`List<Step>`; non-[Step]
/// entries silently filtered) and `currentStep` (int, default `0`).
///
/// Optional: `type` ([StepperType], default [StepperType.vertical]);
/// `onStepTapped` (`(int) -> void` closure); `onStepContinue`,
/// `onStepCancel` (String event names or no-arg closures).
///
/// `controlsBuilder` is intentionally unsupported in this release: the
/// Flutter signature takes a `ControlsDetails` value whose full shape
/// does not round-trip through Rune's source-level value builders
/// cleanly. The default controls are rendered instead; event-driven
/// bindings via `onStepContinue` / `onStepCancel` cover the typical
/// custom-control use case.
final class StepperBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const StepperBuilder();

  @override
  String get typeName => 'Stepper';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final stepsRaw = args.get<List<Object?>>('steps');
    if (stepsRaw == null) {
      throw const ArgumentException(
        'Stepper',
        'Missing required argument "steps"',
      );
    }
    final steps = stepsRaw.whereType<Step>().toList(growable: false);
    return Stepper(
      steps: steps,
      currentStep: args.getOr<int>('currentStep', 0),
      type: args.getOr<StepperType>('type', StepperType.vertical),
      onStepTapped: toIntValueChanged(
        args.named['onStepTapped'],
        'Stepper',
        paramName: 'onStepTapped',
      ),
      onStepContinue: voidEventCallback(
        args.named['onStepContinue'],
        ctx.events,
      ),
      onStepCancel: voidEventCallback(
        args.named['onStepCancel'],
        ctx.events,
      ),
    );
  }
}
