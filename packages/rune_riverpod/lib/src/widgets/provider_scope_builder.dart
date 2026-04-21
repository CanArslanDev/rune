import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rune/rune.dart';

/// Builds a `flutter_riverpod` `ProviderScope`.
///
/// Supported named arguments:
/// - `child` ([Widget], required): the subtree the scope wraps.
///
/// Typically mounted once at the root of the Rune source, above
/// any `RiverpodConsumer` in the tree. Hosts that already install
/// a `ProviderScope` above their `RuneView` can skip this widget
/// in source entirely.
final class ProviderScopeBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const ProviderScopeBuilder();

  @override
  String get typeName => 'ProviderScope';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final child = args.require<Widget>('child', source: 'ProviderScope');
    return ProviderScope(child: child);
  }
}
