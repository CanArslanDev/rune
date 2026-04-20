import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [MaterialPageRoute] as a value.
///
/// Typical use is pairing with `Navigator.push`:
///
/// ```
/// Navigator.push(
///   MaterialPageRoute(builder: (ctx) => DetailPage()),
/// )
/// ```
///
/// Supported named arguments:
/// - `builder` (required `RuneClosure` of arity 1). Receives a
///   [BuildContext] and returns the widget mounted when the route is
///   active.
/// - `settings` ([RouteSettings]?, optional).
/// - `fullscreenDialog` ([bool]?). Defaults to `false`.
/// - `maintainState` ([bool]?). Defaults to `true`.
///
/// The generic type argument is `Object?` so pop results can travel back
/// through Flutter's `Navigator.pop(result)` API; Rune source today
/// ignores the returned future but the channel is preserved for future
/// `await` support.
final class MaterialPageRouteBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const MaterialPageRouteBuilder();

  @override
  String get typeName => 'MaterialPageRoute';

  @override
  String? get constructorName => null;

  @override
  MaterialPageRoute<Object?> build(ResolvedArguments args, RuneContext ctx) {
    final builder = toContextWidgetBuilder(
      args.named['builder'],
      'MaterialPageRoute',
    );
    return MaterialPageRoute<Object?>(
      builder: builder,
      settings: args.get<RouteSettings>('settings'),
      fullscreenDialog: args.getOr<bool>('fullscreenDialog', false),
      maintainState: args.getOr<bool>('maintainState', true),
    );
  }
}
