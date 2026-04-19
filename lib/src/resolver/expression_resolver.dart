import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';

/// Length of the wrapper prefix (`'dynamic __rune__ = '`) prepended by
/// `DartParser` before handing the cleaned source to the analyzer. AST
/// node offsets are reported into the wrapped string; subtracting this
/// constant rebases them into the user-facing source stored on
/// [RuneContext.source]. Duplicated across resolver files to avoid a
/// cross-layer import on `package:rune/src/parser/`; any change here
/// must land alongside the sibling copies in `identifier_resolver.dart`,
/// `property_resolver.dart`, and `invocation_resolver.dart`, and the
/// master in `src/parser/dart_parser.dart`.
const int _wrapperPrefixLength = 19; // 'dynamic __rune__ = '.length

/// Builds a [SourceSpan] for the given [node] against the source on
/// [ctx], rebasing the analyzer-reported offset by
/// [_wrapperPrefixLength].
///
/// When the context holds an empty source string (unit-test contexts
/// that don't care about diagnostics), returns a zero-length span at
/// the origin so callers can still thread a non-null location without
/// branching. When the rebased offset lands outside `[0, source.length]`
/// for any reason (e.g., an AST parsed from a different source string
/// in tests), clamps into range and yields a zero-length span at the
/// clamped position.
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

/// Contract for the invocation resolver injected via [ExpressionResolver.bind].
///
/// Implemented by `InvocationResolver` (Task 15). Declared here (rather than
/// importing the concrete class) so this file does not participate in the
/// circular dependency between the two resolvers.
// ignore: one_member_abstracts
abstract interface class InvocationResolverContract {
  /// Resolves a constructor-call expression — either a [MethodInvocation]
  /// (bare `Text('hi')`) or an [InstanceCreationExpression] (explicit
  /// `new Text('hi')`).
  Object? resolveInvocation(Expression node, RuneContext ctx);
}

/// The top-level expression dispatcher.
///
/// Walks the AST and delegates to specialized resolvers based on the
/// concrete [Expression] subtype. An [InvocationResolverContract] is
/// injected via [bind] to break the circular dependency between it and
/// this class.
final class ExpressionResolver {
  /// Constructs an [ExpressionResolver] wired to a [LiteralResolver] and
  /// [IdentifierResolver]. The invocation resolver is injected later via
  /// [bind].
  ExpressionResolver(this._literal, this._identifier);

  final LiteralResolver _literal;
  final IdentifierResolver _identifier;
  InvocationResolverContract? _invocation;
  PropertyResolver? _property;

  /// Installs the invocation resolver. Must be called exactly once before
  /// any [InstanceCreationExpression] or [MethodInvocation] is resolved.
  void bind(InvocationResolverContract invocation) {
    _invocation = invocation;
  }

  /// Installs the property resolver for `PropertyAccess` dispatch. Must
  /// be called before any `PropertyAccess` expression is resolved.
  void bindProperty(PropertyResolver property) {
    _property = property;
  }

  /// Resolves [expr] within [ctx] and returns the Dart value it denotes.
  ///
  /// Pattern-match order: [StringInterpolation], [ListLiteral], and
  /// [SetOrMapLiteral] are all [Literal] subtypes, so they must be tested
  /// before the broad `Literal()` arm. [PropertyAccess] must be tested
  /// before [PrefixedIdentifier] so receiver-style property access on
  /// non-identifier targets (e.g. `10.px`, `(5).doubled`) routes through
  /// the extension registry. [PrefixedIdentifier] must be tested before
  /// [SimpleIdentifier] because it extends it.
  Object? resolve(Expression expr, RuneContext ctx) {
    return switch (expr) {
      StringInterpolation() => _resolveInterpolation(expr, ctx),
      ListLiteral() => _resolveList(expr, ctx),
      SetOrMapLiteral() => _resolveSetOrMap(expr, ctx),
      IndexExpression() => _resolveIndex(expr, ctx),
      Literal() => _literal.resolve(expr),
      PropertyAccess() => _requireProperty().resolve(expr, ctx),
      PrefixedIdentifier() => _identifier.resolvePrefixed(expr, ctx),
      SimpleIdentifier() => _identifier.resolveSimple(expr, ctx),
      NamedExpression(:final expression) => resolve(expression, ctx),
      ParenthesizedExpression(:final expression) =>
        resolve(expression, ctx),
      InstanceCreationExpression() || MethodInvocation() =>
        _requireInvocation().resolveInvocation(expr, ctx),
      _ => throw ResolveException(
          expr.toSource(),
          'Unsupported expression: ${expr.runtimeType}',
          location: _spanOf(ctx, expr),
        ),
    };
  }

  String _resolveInterpolation(StringInterpolation node, RuneContext ctx) {
    final buffer = StringBuffer();
    for (final element in node.elements) {
      if (element is InterpolationString) {
        buffer.write(element.value);
      } else if (element is InterpolationExpression) {
        final value = resolve(element.expression, ctx);
        buffer.write(value?.toString() ?? '');
      } else {
        throw ResolveException(
          element.toSource(),
          'Unsupported interpolation element: ${element.runtimeType}',
          location: _spanOf(ctx, element),
        );
      }
    }
    return buffer.toString();
  }

  List<Object?> _resolveList(ListLiteral node, RuneContext ctx) {
    final result = <Object?>[];
    for (final element in node.elements) {
      _collectListElement(element, result, ctx);
    }
    return List<Object?>.unmodifiable(result);
  }

  void _collectListElement(
    CollectionElement element,
    List<Object?> result,
    RuneContext ctx,
  ) {
    if (element is Expression) {
      result.add(resolve(element, ctx));
      return;
    }
    if (element is ForElement) {
      _collectForElement(element, result, ctx);
      return;
    }
    throw ResolveException(
      element.toSource(),
      'Unsupported list element: ${element.runtimeType}',
      location: _spanOf(ctx, element),
    );
  }

  void _collectForElement(
    ForElement node,
    List<Object?> result,
    RuneContext ctx,
  ) {
    final parts = node.forLoopParts;
    if (parts is! ForEachPartsWithDeclaration) {
      throw ResolveException(
        node.toSource(),
        'Only for-each with declaration is supported '
        '(for (final x in items)); got ${parts.runtimeType}',
        location: _spanOf(ctx, node),
      );
    }
    final varName = parts.loopVariable.name.lexeme;
    final iterable = resolve(parts.iterable, ctx);
    if (iterable is! Iterable<Object?>) {
      throw ResolveException(
        node.toSource(),
        'for-element iterable must be Iterable, got '
        '${iterable.runtimeType}',
        location: _spanOf(ctx, node),
      );
    }
    for (final item in iterable) {
      final scopedCtx = ctx.copyWith(
        data: ctx.data.extend(<String, Object?>{varName: item}),
      );
      _collectListElement(node.body, result, scopedCtx);
    }
  }

  Object _resolveSetOrMap(SetOrMapLiteral node, RuneContext ctx) {
    final hasMapEntry = node.elements.any((e) => e is MapLiteralEntry);
    if (hasMapEntry) {
      final result = <Object?, Object?>{};
      for (final element in node.elements) {
        if (element is MapLiteralEntry) {
          final key = resolve(element.key, ctx);
          final value = resolve(element.value, ctx);
          result[key] = value;
        } else {
          throw ResolveException(
            element.toSource(),
            'Mixed Set/Map literal is not supported',
            location: _spanOf(ctx, element),
          );
        }
      }
      return Map<Object?, Object?>.unmodifiable(result);
    }
    final result = <Object?>{};
    for (final element in node.elements) {
      if (element is Expression) {
        result.add(resolve(element, ctx));
      } else {
        throw ResolveException(
          element.toSource(),
          'Unsupported set element: ${element.runtimeType}',
          location: _spanOf(ctx, element),
        );
      }
    }
    return Set<Object?>.unmodifiable(result);
  }

  Object? _resolveIndex(IndexExpression node, RuneContext ctx) {
    final targetExpr = node.target;
    if (targetExpr == null) {
      throw ResolveException(
        node.toSource(),
        'Cascade index expressions are not supported',
        location: _spanOf(ctx, node),
      );
    }
    final target = resolve(targetExpr, ctx);
    final index = resolve(node.index, ctx);

    if (target is List<Object?>) {
      if (index is! int) {
        throw ResolveException(
          node.toSource(),
          'List index must be an int, got ${index.runtimeType}',
          location: _spanOf(ctx, node),
        );
      }
      if (index < 0 || index >= target.length) {
        throw ResolveException(
          node.toSource(),
          'Index $index out of range for list of length ${target.length}',
          location: _spanOf(ctx, node),
        );
      }
      return target[index];
    }

    if (target is Map<Object?, Object?>) {
      return target[index];
    }

    throw ResolveException(
      node.toSource(),
      'Cannot index into ${target.runtimeType}',
      location: _spanOf(ctx, node),
    );
  }

  PropertyResolver _requireProperty() {
    final prop = _property;
    if (prop == null) {
      throw StateError(
        'ExpressionResolver.bindProperty() was not called — '
        'cannot resolve PropertyAccess.',
      );
    }
    return prop;
  }

  InvocationResolverContract _requireInvocation() {
    final inv = _invocation;
    if (inv == null) {
      throw StateError(
        'ExpressionResolver.bind() was not called — '
        'cannot resolve InstanceCreationExpression or MethodInvocation.',
      );
    }
    return inv;
  }
}
