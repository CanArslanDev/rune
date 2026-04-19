import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Semantics] — an accessibility annotation wrapper.
///
/// Covers the most commonly authored properties: `label`, `value`,
/// `hint`, plus boolean role flags (`button`, `link`, `header`,
/// `image`), plus `excludeSemantics` (default `false`) and `container`
/// (default `false`). The remaining `SemanticsProperties` (actions,
/// handlers, advanced flags) are intentionally omitted — they require
/// callback or specialised-value support that source-authored
/// `Semantics` nodes rarely need.
final class SemanticsBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SemanticsBuilder();

  @override
  String get typeName => 'Semantics';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Semantics(
      label: args.get<String>('label'),
      value: args.get<String>('value'),
      hint: args.get<String>('hint'),
      button: args.get<bool>('button'),
      link: args.get<bool>('link'),
      header: args.get<bool>('header'),
      image: args.get<bool>('image'),
      excludeSemantics: args.getOr<bool>('excludeSemantics', false),
      container: args.getOr<bool>('container', false),
      child: args.get<Widget>('child'),
    );
  }
}
