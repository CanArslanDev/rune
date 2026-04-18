import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

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

  /// Resolves [node] to the value bound under `node.name` in `ctx.data`.
  Object? resolveSimple(SimpleIdentifier node, RuneContext ctx) {
    final key = node.name;
    if (!ctx.data.has(key)) {
      throw BindingException(
        node.toSource(),
        'Unknown identifier "$key" (not present in RuneDataContext)',
      );
    }
    return ctx.data.get(key);
  }

  /// Resolves [node] by checking [RuneContext.data] first, then
  /// [RuneContext.constants].
  ///
  /// If the prefix identifier names a key in `ctx.data` whose value is a
  /// `Map<String, Object?>`, the member is read from that map (`null` when
  /// absent). If the data value is not a Map, a [ResolveException] is
  /// thrown with a type-mismatch message. When the prefix is not in data,
  /// the call falls through to a constants-registry lookup.
  Object? resolvePrefixed(PrefixedIdentifier node, RuneContext ctx) {
    final typeName = node.prefix.name;
    final memberName = node.identifier.name;

    // Data-first: if the prefix names a Map in RuneDataContext, traverse it.
    if (ctx.data.has(typeName)) {
      final holder = ctx.data.get(typeName);
      if (holder is Map<String, Object?>) {
        return holder[memberName];
      }
      throw ResolveException(
        node.toSource(),
        'Expected data value "$typeName" to be a Map for dot-access, '
        'got ${holder.runtimeType}',
      );
    }

    // Fall through to constants.
    return ctx.constants.require(
      typeName,
      memberName,
      source: node.toSource(),
    );
  }
}
