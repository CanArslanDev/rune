import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [PageController] from Dart's default constructor.
///
/// Source arguments (all optional):
/// - `initialPage` (`int`): first page index shown when attached.
///   Defaults to `0`.
/// - `keepPage` (`bool`): whether the current page survives rebuilds
///   via [PageStorage]. Defaults to `true`.
/// - `viewportFraction` (`double`): fraction of the viewport used per
///   page. Defaults to `1.0`; must be greater than `0.0`.
///
/// ```
/// StatefulBuilder(
///   initial: {'ctrl': PageController(initialPage: 1)},
///   dispose: (state) => state.ctrl.dispose(),
///   builder: (state) => PageView(controller: state.ctrl, ...),
/// )
/// ```
final class PageControllerBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const PageControllerBuilder();

  @override
  String get typeName => 'PageController';

  @override
  String? get constructorName => null;

  @override
  PageController build(ResolvedArguments args, RuneContext ctx) {
    return PageController(
      initialPage: args.getOr<int>('initialPage', 0),
      keepPage: args.getOr<bool>('keepPage', true),
      viewportFraction: args.getOr<double>('viewportFraction', 1),
    );
  }
}
