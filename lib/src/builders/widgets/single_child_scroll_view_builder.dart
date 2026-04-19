import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SingleChildScrollView]. Wraps an optional `child` widget in a
/// scrollable region along a chosen [Axis].
///
/// Supported arguments: `scrollDirection` ([Axis], default
/// [Axis.vertical]), `reverse` (bool, default false), `padding`
/// ([EdgeInsetsGeometry]), `controller` ([ScrollController], optional),
/// `child` ([Widget]). `primary` and `physics` are out of scope; they
/// require types not currently reachable from Rune source syntax.
///
/// When the optional `controller` is supplied (typically constructed via
/// a `StatefulBuilder`'s `initial` map), disposal stays with the
/// source-level owner.
final class SingleChildScrollViewBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const SingleChildScrollViewBuilder();

  @override
  String get typeName => 'SingleChildScrollView';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return SingleChildScrollView(
      scrollDirection: args.getOr<Axis>('scrollDirection', Axis.vertical),
      reverse: args.getOr<bool>('reverse', false),
      padding: args.get<EdgeInsetsGeometry>('padding'),
      controller: args.get<ScrollController>('controller'),
      child: args.get<Widget>('child'),
    );
  }
}
