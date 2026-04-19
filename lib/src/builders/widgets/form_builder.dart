import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a Material [Form] that groups [TextFormField]s for shared
/// validation, save, and reset.
///
/// Source arguments:
/// - `child` ([Widget], required) -- the form's subtree, typically a
///   [Column] of [TextFormField]s plus a submit button.
/// - `onChanged` (`String` or closure) -- fires each time any contained
///   form field's value changes. A `String` dispatches the named event
///   through [RuneContext.events]; a closure `() => ...` is invoked
///   directly.
/// - `autovalidateMode` ([AutovalidateMode]) -- defaults to
///   [AutovalidateMode.disabled]. Use `AutovalidateMode.always` to
///   revalidate every frame, `onUserInteraction` to validate each field
///   after first touch, `onUnfocus` to validate on focus loss.
///
/// The `canPop` / `onPopInvoked` pop-interception slots are deliberately
/// left out of v1.5.0 -- they bind naturally to navigation work landing
/// in a later release.
final class FormBuilder implements RuneWidgetBuilder {
  /// Const constructor -- the builder is stateless.
  const FormBuilder();

  @override
  String get typeName => 'Form';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Form(
      onChanged: voidEventCallback(args.named['onChanged'], ctx.events),
      autovalidateMode: args.get<AutovalidateMode>('autovalidateMode'),
      child: args.require<Widget>('child', source: 'Form'),
    );
  }
}
