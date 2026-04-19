import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [ScrollController] from Dart's default constructor.
///
/// Source arguments (all optional):
/// - `initialScrollOffset` (`double`): the starting offset new attached
///   scroll positions use. Defaults to `0.0`.
/// - `keepScrollOffset` (`bool`): whether attached scrollables should
///   persist their offset via [PageStorage]. Defaults to `true`.
/// - `debugLabel` (`String`): optional diagnostic label.
///
/// ```
/// StatefulBuilder(
///   initial: {'ctrl': ScrollController()},
///   dispose: (state) => state.ctrl.dispose(),
///   builder: (state) => ListView(controller: state.ctrl, ...),
/// )
/// ```
///
/// The controller is returned as-is; callers are responsible for disposal.
final class ScrollControllerBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const ScrollControllerBuilder();

  @override
  String get typeName => 'ScrollController';

  @override
  String? get constructorName => null;

  @override
  ScrollController build(ResolvedArguments args, RuneContext ctx) {
    return ScrollController(
      initialScrollOffset: args.getOr<double>('initialScrollOffset', 0),
      keepScrollOffset: args.getOr<bool>('keepScrollOffset', true),
      debugLabel: args.get<String>('debugLabel'),
    );
  }
}
