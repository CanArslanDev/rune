import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/resolver/expression_resolver.dart';

/// Resolves [PropertyAccess] AST nodes — receiver-style dotted property
/// access like `10.px`, `(5).doubled`, `user.profile.name`.
///
/// Dispatch order for each node:
/// 1. Resolve the target via the injected [ExpressionResolver].
/// 2. If the resolved target is a `Map<String, Object?>`, return
///    `target[propertyName]` (missing keys yield `null`). Data wins
///    over extensions on conflict.
/// 3. Otherwise, look up the property in `ctx.extensions` via
///    `require`, which throws `ResolveException` on miss.
///
/// Does not handle `PrefixedIdentifier` — that's `IdentifierResolver`'s
/// job (`Colors.red` and shallow `user.name` flow through there).
final class PropertyResolver {
  /// Constructs a [PropertyResolver] that delegates target resolution
  /// to [_expr].
  PropertyResolver(this._expr);

  final ExpressionResolver _expr;

  /// Resolves [node] within [ctx]. See class-level dartdoc for dispatch
  /// rules.
  Object? resolve(PropertyAccess node, RuneContext ctx) {
    final target = _expr.resolve(node.target!, ctx);
    final propName = node.propertyName.name;

    if (target is Map<String, Object?>) {
      return target[propName];
    }

    return ctx.extensions.require(
      propName,
      target,
      ctx,
      source: node.toSource(),
      location: SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
    );
  }
}
