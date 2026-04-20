import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [PageRouteBuilder] as a value (v1.12.0). Pairs with
/// `Navigator.push` when source wants a custom enter/exit transition
/// rather than the platform default that `MaterialPageRoute` supplies.
///
/// Source arguments:
/// - `pageBuilder` (required, closure
///   `(ctx, animation, secondaryAnimation) => Widget`).
/// - `transitionsBuilder` (optional, closure
///   `(ctx, animation, secondaryAnimation, child) => Widget`). Defaults
///   to the identity transition (`child`) if omitted, matching Flutter's
///   own default.
/// - `transitionDuration` ([Duration]?). Defaults to 300ms.
/// - `reverseTransitionDuration` ([Duration]?). Defaults to 300ms.
/// - `barrierDismissible` ([bool]?). Defaults to `false`.
final class PageRouteBuilderBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const PageRouteBuilderBuilder();

  @override
  String get typeName => 'PageRouteBuilder';

  @override
  String? get constructorName => null;

  @override
  PageRouteBuilder<Object?> build(ResolvedArguments args, RuneContext ctx) {
    final pageBuilder = toPageRouteBuilderPageBuilder(
      args.named['pageBuilder'],
      'PageRouteBuilder',
    );
    final transitionsBuilderSource = args.named['transitionsBuilder'];
    final RouteTransitionsBuilder transitionsBuilder;
    if (transitionsBuilderSource == null) {
      transitionsBuilder = (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          child;
    } else {
      transitionsBuilder = toPageRouteBuilderTransitionsBuilder(
        transitionsBuilderSource,
        'PageRouteBuilder',
      );
    }
    return PageRouteBuilder<Object?>(
      pageBuilder: pageBuilder,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: args.getOr<Duration>(
        'transitionDuration',
        const Duration(milliseconds: 300),
      ),
      reverseTransitionDuration: args.getOr<Duration>(
        'reverseTransitionDuration',
        const Duration(milliseconds: 300),
      ),
      barrierDismissible: args.getOr<bool>('barrierDismissible', false),
    );
  }
}
