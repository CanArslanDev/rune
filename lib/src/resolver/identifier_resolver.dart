import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Resolves identifier-shaped expressions to their runtime Dart values.
///
/// - [SimpleIdentifier] (e.g. `userName`) → looked up in
///   [RuneContext.data]; throws [BindingException] when the key is absent.
/// - [PrefixedIdentifier] (e.g. `Colors.red`) → looked up in
///   [RuneContext.constants]; throws [ResolveException] when the
///   `typeName.memberName` pair is unknown.
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

  /// Resolves [node] by composing `prefix.name` + `identifier.name` into a
  /// constant-registry lookup.
  Object? resolvePrefixed(PrefixedIdentifier node, RuneContext ctx) {
    final typeName = node.prefix.name;
    final memberName = node.identifier.name;
    return ctx.constants.require(
      typeName,
      memberName,
      source: node.toSource(),
    );
  }
}
