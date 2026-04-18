import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/resolver/literal_resolver.dart';

/// Contract for the invocation resolver injected via [ExpressionResolver.bind].
///
/// Implemented by `InvocationResolver` (Task 15). Declared here (rather than
/// importing the concrete class) so this file does not participate in the
/// circular dependency between the two resolvers.
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
  /// Constructs an [ExpressionResolver] wired to a [LiteralResolver]. The
  /// invocation resolver is injected later via [bind].
  ExpressionResolver(this._literal);

  final LiteralResolver _literal;
  InvocationResolverContract? _invocation;

  /// Installs the invocation resolver. Must be called exactly once before
  /// any `InstanceCreationExpression` or `MethodInvocation` is resolved.
  void bind(InvocationResolverContract invocation) {
    _invocation = invocation;
  }

  /// Resolves [expr] within [ctx] and returns the Dart value it denotes.
  ///
  /// Pattern-match order matters: [ListLiteral] is a [Literal] subtype, so
  /// it must be tested before the broad `Literal()` arm.
  Object? resolve(Expression expr, RuneContext ctx) {
    return switch (expr) {
      ListLiteral() => _resolveList(expr, ctx),
      Literal() => _literal.resolve(expr),
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

  InvocationResolverContract _requireInvocation() {
    final InvocationResolverContract? inv = _invocation;
    if (inv == null) {
      throw StateError(
        'ExpressionResolver.bind() was not called — '
        'cannot resolve InstanceCreationExpression or MethodInvocation.',
      );
    }
    return inv;
  }
}
