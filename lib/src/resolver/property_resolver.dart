import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/resolver/builtin_members.dart';
import 'package:rune/src/resolver/expression_resolver.dart';

/// Resolves [PropertyAccess] AST nodes — receiver-style dotted property
/// access like `10.px`, `(5).doubled`, `user.profile.name`,
/// `'hello'.length`, `cart.items.length`.
///
/// Dispatch order for each node:
/// 1. Resolve the target via the injected [ExpressionResolver].
/// 2. If the resolved target is a `Map<String, Object?>` AND the map
///    contains the property name as a key, return `target[propName]`.
///    This preserves the data-first invariant: when the user's data
///    explicitly names the property, that value wins over any built-in
///    or extension of the same name.
/// 3. Otherwise, consult the built-in member whitelist (see
///    `builtin_members.dart`). This covers idiomatic Dart accessors
///    like `.length`, `.isEmpty`, `.first`, `.keys`, etc. on String,
///    List, and Map. This means that a Map whose property name is NOT
///    an explicit key now surfaces the Map's own accessors (e.g., an
///    empty-key-set Map asking for `.length` yields the Map's size
///    rather than a silent `null`). Documented in the CHANGELOG.
/// 4. Finally, fall through to `ctx.extensions` via `require`, which
///    throws `ResolveException` on miss. Bridge-registered extensions
///    (e.g., `.w`, `.h`, `.px` from `rune_responsive_sizer`) remain
///    reachable this way — they fire when their property name is
///    neither a Map key nor a built-in member.
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

    // 1. Map key present → data-first semantics.
    if (target is Map<String, Object?> && target.containsKey(propName)) {
      return target[propName];
    }

    // 2. Built-in property on String / List / Map / etc.
    final (hit, value) = resolveBuiltinProperty(target, propName);
    if (hit) return value;

    // 3. Map with absent key and no built-in match — preserve the legacy
    // map-absent-key → null semantics rather than escalating to an
    // extension miss. A Map's shape says "arbitrary key space", so an
    // unknown member is data-absent rather than a missing extension.
    if (target is Map<String, Object?>) {
      return null;
    }

    // 4. Bridge-registered extension (or miss → ResolveException).
    return ctx.extensions.require(
      propName,
      target,
      ctx,
      source: node.toSource(),
      location: SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
    );
  }
}
