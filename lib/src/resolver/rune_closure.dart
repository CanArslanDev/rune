import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/foundation.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/resolver/expression_resolver.dart';

/// A callable value produced by resolving a [FunctionExpression] AST
/// node.
///
/// Invocation evaluates the body expression (arrow-body form only in
/// Phase A.1; block bodies arrive in a later phase) against the captured
/// [RuneContext] extended with the arguments bound to the declared
/// parameter names.
///
/// Rune closures are whitelist-bound: their body can only use the same
/// resolver primitives that any other Rune source expression uses.
/// There is no arbitrary Dart execution. This preserves the
/// store-compliance posture.
@immutable
final class RuneClosure {
  /// Constructs a closure over [body] with [parameterNames] declared in
  /// order.
  ///
  /// [capturedContext] is the [RuneContext] at the point of closure
  /// creation; calls extend its [RuneContext.data] with the argument
  /// bindings. [resolver] is the [ExpressionResolver] used to evaluate
  /// [body] on each call.
  const RuneClosure({
    required this.parameterNames,
    required this.body,
    required this.capturedContext,
    required this.resolver,
  });

  /// Names of the formal parameters in declaration order.
  ///
  /// Phase A.1 supports only required positional parameters; optional
  /// and named parameters are out of scope.
  final List<String> parameterNames;

  /// The arrow-body expression to evaluate on each call.
  ///
  /// Block-body function literals are rejected at construction time by
  /// [ExpressionResolver], so [body] is always a plain [Expression].
  final Expression body;

  /// The context captured at closure-creation time.
  ///
  /// Calls extend this context's [RuneContext.data] with the argument
  /// bindings before re-entering [resolver].
  final RuneContext capturedContext;

  /// The expression resolver used to evaluate [body] on each call.
  final ExpressionResolver resolver;

  /// Invokes the closure with [positionalArgs].
  ///
  /// Arity must match [parameterNames].length exactly. Phase A.1 does
  /// not support optional or named parameters. Arity mismatch raises
  /// [ResolveException] citing the body's source.
  Object? call(List<Object?> positionalArgs) {
    if (positionalArgs.length != parameterNames.length) {
      throw ResolveException(
        body.toSource(),
        'Closure arity mismatch: expected ${parameterNames.length} '
        'positional arguments, got ${positionalArgs.length}',
      );
    }
    final extendedData = capturedContext.data.extend(
      Map<String, Object?>.fromIterables(parameterNames, positionalArgs),
    );
    final extendedContext = capturedContext.copyWith(data: extendedData);
    return resolver.resolve(body, extendedContext);
  }

  @override
  String toString() =>
      'RuneClosure(${parameterNames.join(', ')}) => ${body.toSource()}';
}
