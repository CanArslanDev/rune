import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SliverPadding] — edge padding around a nested sliver.
///
/// Required: `padding: EdgeInsetsGeometry`. Optional: `sliver: Widget`
/// (a sliver-protocol widget).
final class SliverPaddingBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SliverPaddingBuilder();

  @override
  String get typeName => 'SliverPadding';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return SliverPadding(
      padding: args.require<EdgeInsetsGeometry>(
        'padding',
        source: 'SliverPadding',
      ),
      sliver: args.get<Widget>('sliver'),
    );
  }
}
