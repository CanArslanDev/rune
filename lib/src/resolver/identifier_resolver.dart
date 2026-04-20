import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/rune_state.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/resolver/builtin_members.dart';

/// Resolves identifier-shaped expressions to their runtime Dart values.
///
/// - [SimpleIdentifier] (e.g. `userName`) → looked up in
///   [RuneContext.data]; throws [BindingException] when the key is absent.
/// - [PrefixedIdentifier] (e.g. `Colors.red`) → data-first: if the prefix
///   names a key in [RuneContext.data] whose value is a
///   `Map<String, Object?>`, looks up the member there and returns it
///   (missing members return `null`). If the data value is not a Map,
///   throws [ResolveException] with a type-mismatch message. If the prefix
///   is not in data, falls through to [RuneContext.constants]; throws
///   [ResolveException] when the `typeName.memberName` pair is unknown.
final class IdentifierResolver {
  /// Constructs an [IdentifierResolver]. Stateless; cheap to instantiate.
  IdentifierResolver();

  /// Resolves [node] to the value bound under `node.name`.
  ///
  /// Dispatch order: local scope (if any) → data. Local-scope
  /// declarations introduced by block-body closures take precedence
  /// over host-supplied data of the same name, matching Dart's lexical
  /// scoping rules. A missing name in BOTH scope and data raises
  /// [BindingException].
  Object? resolveSimple(SimpleIdentifier node, RuneContext ctx) {
    final key = node.name;
    final scope = ctx.scope;
    if (scope != null && scope.has(key)) {
      return scope.lookup(key);
    }
    if (!ctx.data.has(key)) {
      throw BindingException.withSuggestion(
        source: node.toSource(),
        baseMessage:
            'Unknown identifier "$key" (not present in RuneDataContext)',
        candidate: key,
        candidates: _simpleIdentifierCandidates(ctx),
        location:
            SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
      );
    }
    return ctx.data.get(key);
  }

  /// Names visible to a bare `SimpleIdentifier` lookup: the current
  /// scope's declarations (if any) followed by the host-supplied data
  /// keys. Constants are NOT folded in here — constants always live
  /// under a `Type.member` prefix in source, so suggesting one would
  /// misfire (the user wrote `foo`, the fix is a data key or a scope
  /// variable, not `Colors.red`).
  Iterable<String> _simpleIdentifierCandidates(RuneContext ctx) sync* {
    final scope = ctx.scope;
    if (scope != null) {
      yield* scope.names;
    }
    yield* ctx.data.keys;
  }

  /// Resolves [node] by checking [RuneContext.data] first, then
  /// built-in members, then [RuneContext.constants].
  ///
  /// Dispatch order:
  ///
  /// 1. **Data-first:** if the prefix names a key in `ctx.data` whose
  ///    value is a `Map<String, Object?>` AND the map contains the
  ///    member name as a key, return `map[memberName]`. If the map does
  ///    NOT contain that key, fall through to built-in members — this
  ///    mirrors `PropertyResolver`'s precedence so `cart.length` on a
  ///    Map without a `length` key yields the Map's own size rather
  ///    than a silent `null`.
  /// 2. **Data non-Map:** if the prefix names a non-Map data value
  ///    (e.g. a String, List, or num), consult the built-in member
  ///    whitelist. A hit returns the built-in value; a miss raises
  ///    [ResolveException] with a type-mismatch message (preserving the
  ///    diagnostic users got before built-ins existed).
  /// 3. **Constants:** if the prefix is not in data at all, fall through
  ///    to [RuneContext.constants] (e.g. `Colors.red`).
  Object? resolvePrefixed(PrefixedIdentifier node, RuneContext ctx) {
    final typeName = node.prefix.name;
    final memberName = node.identifier.name;

    // Data-first: if the prefix names a data value, traverse it.
    if (ctx.data.has(typeName)) {
      final holder = ctx.data.get(typeName);

      // Map: key-present wins; key-absent falls through to built-ins
      // (e.g., `cart.length` on a Map without a "length" key).
      if (holder is Map<String, Object?>) {
        if (holder.containsKey(memberName)) {
          return holder[memberName];
        }
        final (hit, value) = resolveBuiltinProperty(holder, memberName);
        if (hit) return value;
        // Preserve legacy absent-key → null semantics for Maps when the
        // member is neither a key nor a built-in.
        return null;
      }

      // RuneState: mirror the Map branch — entry-present wins,
      // absent falls through to null to match Map semantics.
      if (holder is RuneState) {
        if (holder.has(memberName)) {
          return holder.get(memberName);
        }
        return null;
      }

      // Non-Map data: consult built-in whitelist (String / List / num).
      final (hit, value) = resolveBuiltinProperty(holder, memberName);
      if (hit) return value;

      // v1.17.0 MemberRegistry: user-registered property on a custom
      // type reached via `data.prefix.member`. Fires only when the
      // holder is not a built-in target AND the member is registered;
      // a miss falls through to the diagnostic below so the existing
      // "expected data value to be a Map" error remains the default.
      final members = ctx.members;
      if (members != null) {
        final (memberHit, memberValue) =
            members.resolveProperty(holder, memberName, ctx);
        if (memberHit) return memberValue;
      }

      final location =
          SourceSpan.fromAstOffset(ctx.source, node.offset, node.length);
      final typeLabel = builtinTargetTypeLabel(holder);
      final baseMessage =
          'Expected data value "$typeName" to be a Map for dot-access, '
          'got ${holder.runtimeType}';
      if (typeLabel != null) {
        final builtin = builtinPropertiesFor(typeLabel);
        if (builtin.isNotEmpty) {
          throw ResolveException.withSuggestion(
            source: node.toSource(),
            baseMessage: baseMessage,
            candidate: memberName,
            candidates: builtin,
            location: location,
          );
        }
      }
      throw ResolveException(
        node.toSource(),
        baseMessage,
        location: location,
      );
    }

    // Fall through to constants. If the constant pair is unknown, we
    // take over the exception construction so the "did you mean ...?"
    // trailer reflects whichever half of `typeName.memberName` is more
    // likely the misspelling: if the type exists but the member
    // doesn't, suggest a sibling member; otherwise suggest a type.
    if (ctx.constants.contains(typeName, memberName)) {
      return ctx.constants.resolve(typeName, memberName);
    }
    final location =
        SourceSpan.fromAstOffset(ctx.source, node.offset, node.length);
    final memberNames = ctx.constants.memberNamesOf(typeName);
    if (memberNames.isNotEmpty) {
      // The type is registered — the user got the member wrong.
      throw ResolveException.withSuggestion(
        source: node.toSource(),
        baseMessage: 'Unknown constant "$typeName.$memberName"',
        candidate: memberName,
        candidates: memberNames,
        location: location,
      );
    }
    throw ResolveException.withSuggestion(
      source: node.toSource(),
      baseMessage: 'Unknown constant "$typeName.$memberName"',
      candidate: typeName,
      candidates: ctx.constants.typeNames,
      location: location,
    );
  }
}
