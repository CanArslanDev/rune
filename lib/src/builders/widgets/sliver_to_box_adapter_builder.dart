import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SliverToBoxAdapter] from an optional `child: Widget`.
///
/// Wraps a regular (non-sliver) widget so it can participate in a
/// [CustomScrollView]'s `slivers` list. The child is rendered in its
/// natural size.
final class SliverToBoxAdapterBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SliverToBoxAdapterBuilder();

  @override
  String get typeName => 'SliverToBoxAdapter';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return SliverToBoxAdapter(child: args.get<Widget>('child'));
  }
}
