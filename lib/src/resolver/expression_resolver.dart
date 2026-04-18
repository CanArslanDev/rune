import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';

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

  /// Installs the invocation resolver. Must be called exactly once before
  /// any [InstanceCreationExpression] or [MethodInvocation] is resolved.
  void bind(InvocationResolverContract invocation) {
    _invocation = invocation;
  }

  /// Resolves [expr] within [ctx] and returns the Dart value it denotes.
  ///
  /// Pattern-match order: [StringInterpolation], [ListLiteral], and
  /// [SetOrMapLiteral] are all [Literal] subtypes, so they must be tested
  /// before the broad `Literal()` arm. [PrefixedIdentifier] must be
  /// tested before [SimpleIdentifier] because it extends it.
  Object? resolve(Expression expr, RuneContext ctx) {
    return switch (expr) {
      StringInterpolation() => _resolveInterpolation(expr, ctx),
      ListLiteral() => _resolveList(expr, ctx),
      SetOrMapLiteral() => _resolveSetOrMap(expr, ctx),
      Literal() => _literal.resolve(expr),
      PrefixedIdentifier() => _identifier.resolvePrefixed(expr, ctx),
      SimpleIdentifier() => _identifier.resolveSimple(expr, ctx),
      NamedExpression(:final expression) => resolve(expression, ctx),
      ParenthesizedExpression(:final expression) => resolve(expression, ctx),
      InstanceCreationExpression() || MethodInvocation() =>
        _requireInvocation().resolveInvocation(expr, ctx),
      _ => throw ResolveException(
          expr.toSource(),
          'Unsupported expression: ${expr.runtimeType}',
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
        );
      }
    }
    return buffer.toString();
  }

  List<Object?> _resolveList(ListLiteral node, RuneContext ctx) {
    final result = <Object?>[];
    for (final element in node.elements) {
      if (element is Expression) {
        result.add(resolve(element, ctx));
      } else {
        throw ResolveException(
          element.toSource(),
          'Unsupported list element: ${element.runtimeType}',
        );
      }
    }
    return List<Object?>.unmodifiable(result);
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
        );
      }
    }
    return Set<Object?>.unmodifiable(result);
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
