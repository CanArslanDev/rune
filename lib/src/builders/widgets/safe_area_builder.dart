import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SafeArea] — insets its required `child` away from the
/// OS-reported system UI intrusions (notches, status bar, home
/// indicator).
///
/// Per-edge toggles (`left`, `top`, `right`, `bottom`) all default
/// to `true`. Optional `minimum` ([EdgeInsets]; defaults to
/// [EdgeInsets.zero]) sets a floor that the inset never drops below.
/// `maintainBottomViewPadding` defaults to `false`.
///
/// The `minimum` slot is typed as [EdgeInsets] (not the geometric
/// supertype) to match the underlying SafeArea parameter; source
/// callers supply it via `EdgeInsets.all(...)` / `symmetric(...)` /
/// `only(...)` / `fromLTRB(...)` / `zero`.
final class SafeAreaBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const SafeAreaBuilder();

  @override
  String get typeName => 'SafeArea';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return SafeArea(
      left: args.getOr<bool>('left', true),
      top: args.getOr<bool>('top', true),
      right: args.getOr<bool>('right', true),
      bottom: args.getOr<bool>('bottom', true),
      minimum: args.getOr<EdgeInsets>('minimum', EdgeInsets.zero),
      maintainBottomViewPadding: args.getOr<bool>(
        'maintainBottomViewPadding',
        false,
      ),
      child: args.require<Widget>('child', source: 'SafeArea'),
    );
  }
}
