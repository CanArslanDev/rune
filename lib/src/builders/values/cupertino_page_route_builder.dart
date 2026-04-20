import 'package:flutter/cupertino.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [CupertinoPageRoute] as a value.
///
/// Shape mirrors `MaterialPageRoute` but adds an optional `title` that
/// Cupertino navigation surfaces show in the back-swipe chrome.
///
/// Supported named arguments:
/// - `builder` (required `RuneClosure` of arity 1). Receives a
///   [BuildContext] and returns the widget mounted when the route is
///   active.
/// - `settings` ([RouteSettings]?, optional).
/// - `title` ([String]?, optional).
/// - `fullscreenDialog` ([bool]?). Defaults to `false`.
/// - `maintainState` ([bool]?). Defaults to `true`.
final class CupertinoPageRouteBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoPageRouteBuilder();

  @override
  String get typeName => 'CupertinoPageRoute';

  @override
  String? get constructorName => null;

  @override
  CupertinoPageRoute<Object?> build(ResolvedArguments args, RuneContext ctx) {
    final builder = toContextWidgetBuilder(
      args.named['builder'],
      'CupertinoPageRoute',
    );
    return CupertinoPageRoute<Object?>(
      builder: builder,
      settings: args.get<RouteSettings>('settings'),
      title: args.get<String>('title'),
      fullscreenDialog: args.getOr<bool>('fullscreenDialog', false),
      maintainState: args.getOr<bool>('maintainState', true),
    );
  }
}
