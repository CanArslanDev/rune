import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [Checkbox] with two-way value binding.
///
/// Source arguments:
/// - `value` (`bool?`) — current state. `null` is meaningful only when
///   `tristate: true`; otherwise the underlying [Checkbox] asserts.
/// - `tristate` (`bool`) — when `true`, the checkbox cycles through
///   `false → true → null → false`. Defaults to `false`.
/// - `onChanged` (`String`) — event name to dispatch on toggle. The new
///   value (`bool?` — may be `null` under `tristate: true`) is forwarded
///   as the sole argument. Missing `onChanged` disables the checkbox.
///
/// Note: when `tristate: false` (the default), `value` is required at
/// the source level — Flutter's [Checkbox] rejects `null` in that mode.
final class CheckboxBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const CheckboxBuilder();

  @override
  String get typeName => 'Checkbox';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final value = args.get<bool>('value');
    final tristate = args.getOr<bool>('tristate', false);
    final eventName = args.get<String>('onChanged');
    return Checkbox(
      value: value,
      tristate: tristate,
      onChanged: eventName == null
          ? null
          : (next) => ctx.events.dispatch(eventName, <Object?>[next]),
    );
  }
}
