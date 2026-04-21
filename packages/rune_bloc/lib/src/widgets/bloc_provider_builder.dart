import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rune/rune.dart';
import 'package:rune_bloc/src/closure_helpers.dart';

/// Builds a `BlocProvider<BlocBase<Object?>>` that exposes a
/// `Cubit` / `Bloc` to its subtree.
///
/// Exactly one of `create:` or `value:` must be supplied.
///
/// - `create` (closure `(ctx) -> BlocBase<Object?>`): called
///   lazily on first mount. The bloc is auto-closed when the
///   provider unmounts (matches `flutter_bloc`'s default).
/// - `value` (`BlocBase<Object?>`): uses an existing bloc; the
///   provider does NOT close it on unmount (caller owns the
///   lifecycle).
/// - `child` ([Widget], required): the subtree that can read the
///   bloc via `BlocBuilder` / `BlocListener`.
/// - `lazy` ([bool]?, default `true`): forwarded to `flutter_bloc`.
final class BlocProviderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const BlocProviderBuilder();

  @override
  String get typeName => 'BlocProvider';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final child = args.require<Widget>('child', source: 'BlocProvider');
    final hasCreate = args.named.containsKey('create');
    final hasValue = args.named.containsKey('value');

    if (hasCreate == hasValue) {
      throw ArgumentException(
        'BlocProvider',
        hasCreate
            ? 'BlocProvider expects exactly one of `create:` or '
                '`value:`, not both.'
            : 'BlocProvider requires one of `create:` or `value:`.',
      );
    }

    if (hasValue) {
      final value = args.require<BlocBase<Object?>>(
        'value',
        source: 'BlocProvider',
      );
      return BlocProvider<BlocBase<Object?>>.value(
        value: value,
        child: child,
      );
    }

    final factory = toCreate<BlocBase<Object?>>(
      args.named['create'],
      widgetName: 'BlocProvider',
    );
    final lazy = args.get<bool>('lazy') ?? true;
    return BlocProvider<BlocBase<Object?>>(
      create: factory,
      lazy: lazy,
      child: child,
    );
  }
}
