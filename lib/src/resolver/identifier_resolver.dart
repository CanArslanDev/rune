import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/source_span.dart';

/// Length of the wrapper prefix (`'dynamic __rune__ = '`) prepended by
/// `DartParser` before handing the cleaned source to the analyzer. AST
/// node offsets are reported into the wrapped string; subtracting this
/// constant rebases them into the user-facing source stored on
/// [RuneContext.source]. Duplicated across resolver files to avoid a
/// cross-layer import on `package:rune/src/parser/`; any change here
/// must land alongside the sibling copies in `expression_resolver.dart`,
/// `property_resolver.dart`, and `invocation_resolver.dart`, and the
/// master in `src/parser/dart_parser.dart`.
const int _wrapperPrefixLength = 19; // 'dynamic __rune__ = '.length

/// Builds a [SourceSpan] for [node] against the source on [ctx],
/// rebasing the analyzer-reported offset by [_wrapperPrefixLength].
/// Returns a zero-length span at the origin when the source is empty
/// or when the rebased offset lands outside the source's range (both
/// legitimate cases in unit tests).
SourceSpan _spanOf(RuneContext ctx, AstNode node) {
  final source = ctx.source;
  if (source.isEmpty) {
    return SourceSpan.fromOffset('', 0, 0);
  }
  final rebased = node.offset - _wrapperPrefixLength;
  if (rebased < 0 || rebased > source.length) {
    return SourceSpan.fromOffset(source, 0, 0);
  }
  final length = rebased + node.length > source.length
      ? source.length - rebased
      : node.length;
  return SourceSpan.fromOffset(source, rebased, length);
}

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
        location: _spanOf(ctx, node),
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
        location: _spanOf(ctx, node),
      );
    }

    // Fall through to constants.
    return ctx.constants.require(
      typeName,
      memberName,
      source: node.toSource(),
      location: _spanOf(ctx, node),
    );
  }
}
