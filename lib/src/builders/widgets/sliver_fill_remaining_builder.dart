import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SliverFillRemaining] — a sliver that fills whatever remains
/// of the viewport after earlier slivers have laid out.
///
/// Optional: `child: Widget`, `hasScrollBody: bool` (default `true`),
/// `fillOverscroll: bool` (default `false`). The Flutter defaults for
/// these flags are preserved.
final class SliverFillRemainingBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SliverFillRemainingBuilder();

  @override
  String get typeName => 'SliverFillRemaining';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return SliverFillRemaining(
      hasScrollBody: args.getOr<bool>('hasScrollBody', true),
      fillOverscroll: args.getOr<bool>('fillOverscroll', false),
      child: args.get<Widget>('child'),
    );
  }
}
