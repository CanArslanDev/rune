import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [TextButton]. `onPressed` string is wrapped into a `VoidCallback`
/// that dispatches via `ctx.events`. Missing `onPressed` → disabled.
final class TextButtonBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const TextButtonBuilder();

  @override
  String get typeName => 'TextButton';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return TextButton(
      onPressed: voidEventCallback(args.named['onPressed'], ctx.events),
      child: args.get<Widget>('child') ?? const SizedBox.shrink(),
    );
  }
}
