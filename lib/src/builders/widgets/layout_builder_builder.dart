import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [LayoutBuilder] with a `(BuildContext, BoxConstraints) => Widget`
/// `RuneClosure`.
///
/// The builder closure is re-invoked whenever the parent's constraints
/// change. [BoxConstraints] properties (`.maxWidth`, `.minWidth`,
/// `.maxHeight`, `.minHeight`, `.biggest`, `.smallest`) are accessible
/// via the built-in property whitelist.
///
/// Required: `builder: (ctx, constraints) => Widget`.
final class LayoutBuilderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const LayoutBuilderBuilder();

  @override
  String get typeName => 'LayoutBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final builder = toLayoutBuilder(
      args.named['builder'],
      'LayoutBuilder',
    );
    return LayoutBuilder(builder: builder);
  }
}
