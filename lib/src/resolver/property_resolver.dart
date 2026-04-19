import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/resolver/expression_resolver.dart';

/// Length of the wrapper prefix (`'dynamic __rune__ = '`) prepended by
/// `DartParser` before handing the cleaned source to the analyzer. AST
/// node offsets are reported into the wrapped string; subtracting this
/// constant rebases them into the user-facing source stored on
/// [RuneContext.source]. Duplicated across resolver files to avoid a
/// cross-layer import on `package:rune/src/parser/`; any change here
/// must land alongside the sibling copies in `expression_resolver.dart`,
/// `identifier_resolver.dart`, and `invocation_resolver.dart`, and the
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
      location: _spanOf(ctx, node),
    );
  }
}
