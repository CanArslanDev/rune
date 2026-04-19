import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SliverList] via `SliverList.list(...)` from an optional
/// `children: List<Widget>`.
///
/// Non-Widget entries are dropped silently (children-filter
/// convention). `SliverList.builder` — the closure-based lazy variant —
/// is deferred pending function-literal support in Rune source.
final class SliverListBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SliverListBuilder();

  @override
  String get typeName => 'SliverList';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final children = (args.get<List<Object?>>('children') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    return SliverList.list(children: children);
  }
}
