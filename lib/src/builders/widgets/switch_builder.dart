import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [Switch] with two-way value binding.
///
/// Source arguments:
/// - `value` (`bool`) — current on/off state. Defaults to `false`.
/// - `onChanged` (`String`) — event name to dispatch on toggle; the new
///   `bool` is forwarded as the sole argument. A missing `onChanged`
///   leaves the switch's own `onChanged` as `null`, disabling it.
final class SwitchBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SwitchBuilder();

  @override
  String get typeName => 'Switch';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final value = args.getOr<bool>('value', false);
    final eventName = args.get<String>('onChanged');
    return Switch(
      value: value,
      onChanged: eventName == null
          ? null
          : (next) => ctx.events.dispatch(eventName, <Object?>[next]),
    );
  }
}
