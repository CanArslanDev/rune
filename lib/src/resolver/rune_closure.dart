import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/foundation.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/rune_scope.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/statement_resolver.dart';

/// A callable value produced by resolving a [FunctionExpression] AST
/// node.
///
/// Rune closures are whitelist-bound: their body can only use the same
/// resolver primitives that any other Rune source expression uses.
/// There is no arbitrary Dart execution. This preserves the
/// store-compliance posture.
///
/// Two shapes are supported:
///   * Arrow bodies (`(x) => expr`): constructed via
///     [RuneClosure.expression]. At call time the body expression is
///     resolved directly.
///   * Block bodies (`(x) { ...; return expr; }`): constructed via
///     [RuneClosure.block]. At call time a fresh [RuneScope] is
///     allocated and the body's statements are executed via
///     [StatementResolver]; block bodies without an explicit return
///     yield `null`, matching Dart.
@immutable
final class RuneClosure {
  const RuneClosure._({
    required this.parameterNames,
    required this.body,
    required this.bodyBlock,
    required this.capturedContext,
    required this.resolver,
    required this.statementResolver,
  }) : assert(
          (body == null) != (bodyBlock == null),
          'Exactly one of body (arrow) or bodyBlock (block) must be set',
        );

  /// Constructs an arrow-body closure.
  ///
  /// [parameterNames] are the formal parameters in declaration order.
  /// [body] is the expression after `=>`; it is evaluated against the
  /// [capturedContext] extended with argument bindings on each call.
  const RuneClosure.expression({
    required List<String> parameterNames,
    required Expression body,
    required RuneContext capturedContext,
    required ExpressionResolver resolver,
  }) : this._(
          parameterNames: parameterNames,
          body: body,
          bodyBlock: null,
          capturedContext: capturedContext,
          resolver: resolver,
          statementResolver: null,
        );

  /// Constructs a block-body closure.
  ///
  /// [parameterNames] are the formal parameters in declaration order.
  /// [bodyBlock] is the `{ ... }` body; at call time a fresh
  /// [RuneScope] is created, arguments are bound into the captured
  /// data context, and [statementResolver] walks the statements in
  /// order. The returned value is the first [ReturnStatement]'s value,
  /// or `null` if the block falls off the end.
  const RuneClosure.block({
    required List<String> parameterNames,
    required Block bodyBlock,
    required RuneContext capturedContext,
    required ExpressionResolver resolver,
    required StatementResolver statementResolver,
  }) : this._(
          parameterNames: parameterNames,
          body: null,
          bodyBlock: bodyBlock,
          capturedContext: capturedContext,
          resolver: resolver,
          statementResolver: statementResolver,
        );

  /// Names of the formal parameters in declaration order.
  ///
  /// Only required positional parameters are supported. Optional and
  /// named parameters are out of scope.
  final List<String> parameterNames;

  /// The arrow-body expression, or `null` for block bodies.
  final Expression? body;

  /// The block-body block, or `null` for arrow bodies.
  final Block? bodyBlock;

  /// The context captured at closure-creation time.
  ///
  /// Calls extend this context's [RuneContext.data] with the argument
  /// bindings before re-entering [resolver] / [statementResolver].
  final RuneContext capturedContext;

  /// The expression resolver used to evaluate an arrow body or any
  /// sub-expression inside a block body.
  final ExpressionResolver resolver;

  /// The statement resolver used to execute a block body. `null` for
  /// arrow-body closures (where it is not needed).
  final StatementResolver? statementResolver;

  /// Invokes the closure with [positionalArgs].
  ///
  /// Arity must match [parameterNames].length exactly. Arity mismatch
  /// raises [ResolveException] citing the body's source.
  ///
  /// For arrow bodies, returns the body's resolved value. For block
  /// bodies, allocates a fresh [RuneScope] and walks the statements;
  /// returns the first [ReturnStatement]'s value, or `null` if the
  /// block runs off the end.
  Object? call(List<Object?> positionalArgs) {
    if (positionalArgs.length != parameterNames.length) {
      throw ResolveException(
        _bodySource(),
        'Closure arity mismatch: expected ${parameterNames.length} '
        'positional arguments, got ${positionalArgs.length}',
      );
    }
    final extendedData = capturedContext.data.extend(
      Map<String, Object?>.fromIterables(parameterNames, positionalArgs),
    );
    final arrowBody = body;
    if (arrowBody != null) {
      final callCtx = capturedContext.copyWith(data: extendedData);
      return resolver.resolve(arrowBody, callCtx);
    }
    final block = bodyBlock!;
    final bodyScope = RuneScope();
    final callCtx = capturedContext.copyWith(
      data: extendedData,
      scope: bodyScope,
    );
    final result =
        statementResolver!.execute(block.statements.toList(), callCtx);
    return result.returnValue;
  }

  String _bodySource() => body?.toSource() ?? bodyBlock!.toSource();

  @override
  String toString() =>
      'RuneClosure(${parameterNames.join(', ')}) ${_bodyKind()} $_bodySummary';

  String _bodyKind() => body != null ? '=>' : '{...}';

  String get _bodySummary => body?.toSource() ?? bodyBlock!.toSource();
}
