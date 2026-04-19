import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/rune_component_helpers.dart';
import 'package:rune/src/core/rune_component.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [RuneComponent] value from a `RuneComponent(...)` call in
/// source.
///
/// Expected named arguments:
///   * `name` (String): the component's display name used at lookup.
///   * `params` (List of Strings): declared parameter names in order.
///   * `body` (closure): the component body; arity must match
///     `params.length`.
///
/// The builder registers the resulting [RuneComponent] in
/// [RuneContext.components] as a side effect. It also returns the
/// component so source-level expressions can hold a direct reference
/// (useful for debugging and for flexible composition shapes).
///
/// Use inside a `RuneCompose(components: [...], root: ...)` expression
/// so the registrations happen BEFORE `root` is resolved.
final class RuneComponentBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const RuneComponentBuilder();

  @override
  String get typeName => 'RuneComponent';

  @override
  String? get constructorName => null;

  @override
  RuneComponent build(ResolvedArguments args, RuneContext ctx) {
    final component = buildRuneComponent(
      rawName: args.named['name'],
      rawParams: args.named['params'],
      rawBody: args.named['body'],
    );
    ctx.components.register(component);
    return component;
  }
}
