import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material 3 `FilledButton.tonal` as a value (v1.12.0). Registers
/// under `typeName = 'FilledButton'`, `constructorName = 'tonal'`, so
/// source like `FilledButton.tonal(child: Text('x'), onPressed: ...)`
/// dispatches through the value-registry branch of `InvocationResolver`
/// without shadowing the default `FilledButton(...)` widget builder.
///
/// Returns a [Widget] (the tonal-styled `FilledButton`). The Rune
/// resolver does not distinguish widget-producing values from other
/// values: a resolved `Widget` flowing into a `children:` slot works the
/// same way as a `SizedBox(...)` resolved via the widget registry.
///
/// Source arguments:
/// - `onPressed` (`String` event name or `RuneClosure`). Optional; a
///   missing or null value yields a disabled button.
/// - `child` ([Widget]?). Optional; falls back to an empty `SizedBox`
///   for parity with [FilledButton].
final class FilledButtonTonalBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const FilledButtonTonalBuilder();

  @override
  String get typeName => 'FilledButton';

  @override
  String? get constructorName => 'tonal';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return FilledButton.tonal(
      onPressed: voidEventCallback(args.named['onPressed'], ctx.events),
      child: args.get<Widget>('child') ?? const SizedBox.shrink(),
    );
  }
}
