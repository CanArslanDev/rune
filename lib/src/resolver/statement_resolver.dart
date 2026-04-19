import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/rune_scope.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/resolver/expression_resolver.dart';

/// Outcome of executing a sequence of statements.
///
/// `returned` is `true` when a [ReturnStatement] short-circuited the
/// sequence; `returnValue` holds the returned expression's resolved
/// value (or `null` for bare `return;`). When `returned` is `false`,
/// the statement list completed end-to-end without an explicit return
/// and `returnValue` is `null` (matching Dart's semantics for a
/// block-body function that falls off the end).
typedef StatementResult = ({bool returned, Object? returnValue});

const StatementResult _fallthrough = (returned: false, returnValue: null);

/// Executes the sequence of [Statement]s that make up a block-body
/// closure body.
///
/// Phase B supports four statement shapes end-to-end:
///   * [ExpressionStatement]: evaluates the expression and discards
///     the result. An [AssignmentExpression] payload is the primary
///     way source-level code mutates a scope variable.
///   * [ReturnStatement]: short-circuits the sequence and yields the
///     resolved return value (or `null` for bare `return;`).
///   * [VariableDeclarationStatement]: declarator-by-declarator, each
///     name is declared into [RuneContext.scope] (which must be
///     non-null at call time). Multiple declarators in one statement
///     (`var a = 1, b = 2;`) are supported.
///   * [IfStatement]: bool-valued condition controls branch selection;
///     the un-taken branch is not evaluated.
///
/// A raw nested [Block] statement is also supported: it allocates a
/// child [RuneScope] so declarations inside the nested block do not
/// leak outward.
///
/// Every other statement shape (loops, try/catch, switch, break /
/// continue / yield, for-loops) raises [ResolveException] carrying the
/// offending node's span.
final class StatementResolver {
  /// Constructs a [StatementResolver] that dispatches expression
  /// evaluation to [_expressions]. The reverse direction is established
  /// via [ExpressionResolver.bindStatements].
  StatementResolver(this._expressions);

  final ExpressionResolver _expressions;

  /// Executes [statements] in order against [ctx].
  ///
  /// [RuneContext.scope] MUST be non-null when this method is called;
  /// passing a context without a scope is an upstream wiring bug and
  /// raises [StateError]. Short-circuits on the first [ReturnStatement]
  /// encountered.
  StatementResult execute(List<Statement> statements, RuneContext ctx) {
    _requireScope(statements.isEmpty ? null : statements.first, ctx);
    for (final stmt in statements) {
      final r = _executeOne(stmt, ctx);
      if (r.returned) return r;
    }
    return _fallthrough;
  }

  StatementResult _executeOne(Statement stmt, RuneContext ctx) {
    if (stmt is ExpressionStatement) {
      _expressions.resolve(stmt.expression, ctx);
      return _fallthrough;
    }
    if (stmt is ReturnStatement) {
      final expr = stmt.expression;
      final value = expr == null ? null : _expressions.resolve(expr, ctx);
      return (returned: true, returnValue: value);
    }
    if (stmt is VariableDeclarationStatement) {
      final scope = _requireScope(stmt, ctx);
      for (final decl in stmt.variables.variables) {
        final name = decl.name.lexeme;
        final initializer = decl.initializer;
        final value = initializer == null
            ? null
            : _expressions.resolve(initializer, ctx);
        scope.declare(name, value);
      }
      return _fallthrough;
    }
    if (stmt is IfStatement) {
      final cond = _expressions.resolve(stmt.expression, ctx);
      if (cond is! bool) {
        throw ResolveException(
          stmt.expression.toSource(),
          'if-statement condition must be bool, got ${cond.runtimeType}',
          location: SourceSpan.fromAstOffset(
            ctx.source,
            stmt.expression.offset,
            stmt.expression.length,
          ),
        );
      }
      if (cond) return _executeOne(stmt.thenStatement, ctx);
      final elseStmt = stmt.elseStatement;
      if (elseStmt != null) return _executeOne(elseStmt, ctx);
      return _fallthrough;
    }
    if (stmt is Block) {
      final parent = _requireScope(stmt, ctx);
      final childScope = RuneScope.child(parent);
      final childCtx = ctx.copyWith(scope: childScope);
      return execute(stmt.statements.toList(), childCtx);
    }
    throw ResolveException(
      stmt.toSource(),
      'Unsupported statement type: ${stmt.runtimeType}',
      location:
          SourceSpan.fromAstOffset(ctx.source, stmt.offset, stmt.length),
    );
  }

  RuneScope _requireScope(Statement? stmt, RuneContext ctx) {
    final scope = ctx.scope;
    if (scope == null) {
      throw StateError(
        'StatementResolver.execute called with ctx.scope == null; '
        'block-body execution requires a local scope. Upstream bug.',
      );
    }
    return scope;
  }
}
