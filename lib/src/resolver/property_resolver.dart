import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/resolver/expression_resolver.dart';

/// Resolves [PropertyAccess] AST nodes — receiver-style dotted property
/// access like `10.px`, `(5).doubled`, `size.half`.
///
/// For each node, resolves the target expression via the injected
/// [ExpressionResolver], then looks up the property name in
/// `ctx.extensions`. Unknown properties raise a `ResolveException`
/// (propagated from `ExtensionRegistry.require`).
///
/// Does not handle `PrefixedIdentifier` — that's `IdentifierResolver`'s
/// job (`Colors.red` and `user.name` flow through there).
final class PropertyResolver {
  /// Constructs a [PropertyResolver] that delegates target resolution
  /// to [_expr].
  PropertyResolver(this._expr);

  final ExpressionResolver _expr;

  /// Resolves [node] within [ctx].
  Object? resolve(PropertyAccess node, RuneContext ctx) {
    final target = node.target;
    if (target == null) {
      throw ResolveException(
        node.toSource(),
        'Cascade property access is not supported',
      );
    }
    final resolvedTarget = _expr.resolve(target, ctx);
    return ctx.extensions.require(
      node.propertyName.name,
      resolvedTarget,
      ctx,
      source: node.toSource(),
    );
  }
}
