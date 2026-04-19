import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [TextEditingController] from Dart's default constructor.
///
/// Source arguments (all optional):
/// - `text` (`String`): seed text for the controller. Defaults to `null`,
///   matching Dart's default-ctor behaviour (controller starts empty).
///
/// ```
/// StatefulBuilder(
///   initial: {'ctrl': TextEditingController(text: 'hello')},
///   dispose: (state) => state.ctrl.dispose(),
///   builder: (state) => Text(state.ctrl.text),
/// )
/// ```
///
/// The controller is returned as-is; callers are responsible for disposal,
/// typically via `StatefulBuilder.dispose` or `autoDisposeListenables: true`.
final class TextEditingControllerBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const TextEditingControllerBuilder();

  @override
  String get typeName => 'TextEditingController';

  @override
  String? get constructorName => null;

  @override
  TextEditingController build(ResolvedArguments args, RuneContext ctx) {
    return TextEditingController(text: args.get<String>('text'));
  }
}
