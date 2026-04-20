import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/rune_state.dart';
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

    // 1b. RuneState with a matching entry — source-level state access
    // goes through the same data-first path as Map targets.
    if (target is RuneState && target.has(propName)) {
      return target.get(propName);
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

    // 3b. Same legacy absent-key → null for RuneState: the source wrote
    // `state.something` where `something` is neither a set entry nor a
    // recognized RuneState member.
    if (target is RuneState) {
      return null;
    }

    // 4. Bridge-registered extension (hit) — return directly.
    if (ctx.extensions.contains(propName)) {
      return ctx.extensions.resolve(propName, target, ctx);
    }

    // 4b. Miss on every dispatch step. We take over exception
    // construction so the "did you mean ...?" trailer fires against
    // the most relevant candidate pool:
    //   - if the target is a recognized built-in type, suggest one of
    //     the whitelisted properties for that type;
    //   - otherwise, fall back to registered extension names.
    final location =
        SourceSpan.fromAstOffset(ctx.source, node.offset, node.length);
    final typeLabel = builtinTargetTypeLabel(target);
    if (typeLabel != null) {
      final builtin = builtinPropertiesFor(typeLabel);
      if (builtin.isNotEmpty) {
        throw ResolveException.withSuggestion(
          source: node.toSource(),
          baseMessage: 'No built-in property ".$propName" on $typeLabel',
          candidate: propName,
          candidates: builtin,
          location: location,
        );
      }
    }
    throw ResolveException.withSuggestion(
      source: node.toSource(),
      baseMessage: 'Unknown extension property ".$propName"',
      candidate: propName,
      candidates: ctx.extensions.names,
      location: location,
    );
  }
}
