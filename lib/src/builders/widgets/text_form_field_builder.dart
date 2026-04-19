import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [TextFormField] -- a [TextField] enriched with
/// validation, save, and submit lifecycle hooks for use inside a
/// [Form].
///
/// Unlike `TextFieldBuilder`, [TextFormField] manages its own
/// controller lifecycle internally when no external controller is
/// supplied (Flutter's FormField state owns the controller for its
/// lifetime), so the Rune builder does not need a private stateful
/// wrapper.
///
/// Source arguments (all optional):
/// - `value` (`String`) -- forwarded to [TextFormField.initialValue];
///   seeds the field on first mount. Ignored when `controller` is
///   supplied (Flutter constraint: controller-owned text wins).
/// - `controller` ([TextEditingController]) -- an externally-owned
///   controller (typically seeded in a `StatefulBuilder(initial: {...})`
///   and disposed via its `dispose` closure).
/// - `validator` (closure `(String?) -> String?`) -- returns the error
///   message string or `null` when the value is valid. Evaluated on
///   the form's `validate()` / autovalidate tick.
/// - `onSaved` (closure `(String?) -> void`) -- fires when the
///   surrounding form calls `save()`. Typically used to push the
///   saved value back into source-level state.
/// - `onFieldSubmitted` (closure `(String?) -> void`) -- fires when the
///   user submits the field via the soft keyboard.
/// - `onChanged` (`String` or closure `(String?) -> ...`) -- fires on
///   every keystroke with the new text, matching the [TextField]
///   builder's existing contract.
/// - `autovalidateMode` ([AutovalidateMode]) -- when absent, the field
///   follows the enclosing [Form]'s autovalidate policy.
/// - Visual / behavioral args mirror [TextField]: `hintText`,
///   `labelText`, `obscureText` (defaults `false`), `maxLines`
///   (defaults `1`, explicit `null` preserved), `enabled` (defaults
///   `true`).
final class TextFormFieldBuilder implements RuneWidgetBuilder {
  /// Const constructor -- the builder is stateless.
  const TextFormFieldBuilder();

  @override
  String get typeName => 'TextFormField';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final controller = args.get<TextEditingController>('controller');
    // `value` is Flutter's initialValue; only pass when no controller
    // is supplied to avoid Flutter's assertion about providing both.
    final initialValue = controller == null ? args.get<String>('value') : null;
    final maxLines = args.named.containsKey('maxLines')
        ? args.get<int>('maxLines')
        : 1;
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      validator: toValidator(args.named['validator'], 'TextFormField'),
      onSaved: toStringValueChanged(
        args.named['onSaved'],
        'TextFormField',
        paramName: 'onSaved',
      ),
      onFieldSubmitted: valueEventCallback<String>(
        args.named['onFieldSubmitted'],
        ctx.events,
      ),
      onChanged: valueEventCallback<String>(
        args.named['onChanged'],
        ctx.events,
      ),
      autovalidateMode: args.get<AutovalidateMode>('autovalidateMode'),
      obscureText: args.getOr<bool>('obscureText', false),
      maxLines: maxLines,
      enabled: args.getOr<bool>('enabled', true),
      decoration: InputDecoration(
        hintText: args.get<String>('hintText'),
        labelText: args.get<String>('labelText'),
      ),
    );
  }
}
