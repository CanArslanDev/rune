import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `ListView.builder(...)`: a lazily constructed scrollable list
/// whose items are produced by an `itemBuilder` closure evaluated on
/// demand.
///
/// Registered as a [RuneValueBuilder] because `ListView.builder` is a
/// named constructor. Rune dispatches `TypeName.ctor(...)` invocations
/// through the value registry when no plain `TypeName` widget builder
/// matches; the builder still returns a [Widget].
///
/// Required:
/// - `itemCount: int`: number of items the list reports. Pass a large
///   value (e.g. `10000`) to rely entirely on lazy construction.
/// - `itemBuilder: (BuildContext, int) => Widget`: a 2-parameter
///   `RuneClosure` that resolves on demand for each materialised index.
///   Arity / type validation runs at build time via
///   [toIndexedBuilder].
///
/// Optional: `scrollDirection` (Axis, default vertical), `reverse`
/// (bool, default false), `shrinkWrap` (bool, default false), `padding`
/// ([EdgeInsetsGeometry]), `physics` ([ScrollPhysics]), `controller`
/// ([ScrollController]).
///
/// The `BuildContext` argument delivered to the closure is opaque in
/// source for v1.2.0. Accessors like `Theme.of(ctx)` / `MediaQuery.of(ctx)`
/// are deferred to v1.4.0.
final class ListViewBuilderBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const ListViewBuilderBuilder();

  @override
  String get typeName => 'ListView';

  @override
  String? get constructorName => 'builder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final itemCount = args.require<int>(
      'itemCount',
      source: 'ListView.builder',
    );
    final itemBuilder = toIndexedBuilder(
      args.named['itemBuilder'],
      'ListView.builder',
    );
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      scrollDirection: args.getOr<Axis>('scrollDirection', Axis.vertical),
      reverse: args.getOr<bool>('reverse', false),
      shrinkWrap: args.getOr<bool>('shrinkWrap', false),
      padding: args.get<EdgeInsetsGeometry>('padding'),
      physics: args.get<ScrollPhysics>('physics'),
      controller: args.get<ScrollController>('controller'),
    );
  }
}
