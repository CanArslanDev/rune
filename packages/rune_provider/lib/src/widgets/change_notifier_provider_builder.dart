import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart' as p;
import 'package:rune/rune.dart';
import 'package:rune_provider/src/closure_helpers.dart';

/// Builds a `ChangeNotifierProvider<ChangeNotifier>` that exposes a
/// single [ChangeNotifier] to its subtree.
///
/// Supported named arguments (exactly one of `create:` or `value:`
/// must be supplied; supplying both or neither raises
/// [ArgumentException]):
/// - `create` (closure `(ctx) -> ChangeNotifier`) - called lazily on
///   first mount. The notifier is auto-disposed when the provider
///   unmounts (matches `package:provider`'s default behavior).
/// - `value` ([ChangeNotifier]) - an existing instance. The provider
///   does NOT dispose value-provided notifiers; the caller owns the
///   lifecycle.
/// - `child` ([Widget], required) - the subtree rendered under the
///   provider. Descendants consume the notifier via
///   `Consumer(builder: ...)` or `Selector(selector, builder: ...)`.
/// - `lazy` ([bool]? default `true`) - defer `create` until the first
///   consumer mounts. Ignored when `value:` is supplied.
final class ChangeNotifierProviderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const ChangeNotifierProviderBuilder();

  @override
  String get typeName => 'ChangeNotifierProvider';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final child = args.require<Widget>(
      'child',
      source: 'ChangeNotifierProvider',
    );
    final hasCreate = args.named.containsKey('create');
    final hasValue = args.named.containsKey('value');

    if (hasCreate == hasValue) {
      throw ArgumentException(
        'ChangeNotifierProvider',
        hasCreate
            ? 'ChangeNotifierProvider expects exactly one of '
                '`create:` or `value:`, not both.'
            : 'ChangeNotifierProvider requires one of `create:` or '
                '`value:`.',
      );
    }

    if (hasValue) {
      final value = args.require<ChangeNotifier>(
        'value',
        source: 'ChangeNotifierProvider',
      );
      return p.ChangeNotifierProvider<ChangeNotifier>.value(
        value: value,
        child: child,
      );
    }

    final factory = toContextFactory<ChangeNotifier>(
      args.named['create'],
      widgetName: 'ChangeNotifierProvider',
      slotName: 'create',
    );
    final lazy = args.get<bool>('lazy') ?? true;
    return p.ChangeNotifierProvider<ChangeNotifier>(
      create: factory,
      lazy: lazy,
      child: child,
    );
  }
}
