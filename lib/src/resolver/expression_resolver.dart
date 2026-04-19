import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';

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
  /// [SimpleIdentifier] because it extends it. [BinaryExpression],
  /// [PrefixExpression], and [ConditionalExpression] are plain
  /// [Expression] siblings and are placed between [IndexExpression] and
  /// [Literal] purely for readability.
  Object? resolve(Expression expr, RuneContext ctx) {
    return switch (expr) {
      StringInterpolation() => _resolveInterpolation(expr, ctx),
      ListLiteral() => _resolveList(expr, ctx),
      SetOrMapLiteral() => _resolveSetOrMap(expr, ctx),
      IndexExpression() => _resolveIndex(expr, ctx),
      ConditionalExpression() => _resolveConditional(expr, ctx),
      BinaryExpression() => _resolveBinary(expr, ctx),
      PrefixExpression() => _resolvePrefix(expr, ctx),
      Literal() => _literal.resolve(expr),
      PropertyAccess() => _requireProperty().resolve(expr, ctx),
      PrefixedIdentifier() => _identifier.resolvePrefixed(expr, ctx),
      SimpleIdentifier() => _identifier.resolveSimple(expr, ctx),
      NamedExpression(:final expression) => resolve(expression, ctx),
      ParenthesizedExpression(:final expression) => resolve(expression, ctx),
      InstanceCreationExpression() ||
      MethodInvocation() =>
        _requireInvocation().resolveInvocation(expr, ctx),
      _ => throw ResolveException(
          expr.toSource(),
          'Unsupported expression: ${expr.runtimeType}',
          location:
              SourceSpan.fromAstOffset(ctx.source, expr.offset, expr.length),
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
          location: SourceSpan.fromAstOffset(
            ctx.source,
            element.offset,
            element.length,
          ),
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
    if (element is IfElement) {
      _collectIfElement(element, result, ctx);
      return;
    }
    throw ResolveException(
      element.toSource(),
      'Unsupported list element: ${element.runtimeType}',
      location:
          SourceSpan.fromAstOffset(ctx.source, element.offset, element.length),
    );
  }

  void _collectIfElement(
    IfElement node,
    List<Object?> result,
    RuneContext ctx,
  ) {
    if (node.caseClause != null) {
      throw ResolveException(
        node.toSource(),
        'if-case patterns are not supported in list literals',
        location:
            SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
      );
    }
    final cond = resolve(node.expression, ctx);
    if (cond is! bool) {
      throw ResolveException(
        node.toSource(),
        'if-element condition must be bool, got ${cond.runtimeType}',
        location:
            SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
      );
    }
    if (cond) {
      _collectListElement(node.thenElement, result, ctx);
    } else {
      final elseEl = node.elseElement;
      if (elseEl != null) {
        _collectListElement(elseEl, result, ctx);
      }
    }
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
        location:
            SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
      );
    }
    final varName = parts.loopVariable.name.lexeme;
    final iterable = resolve(parts.iterable, ctx);
    if (iterable is! Iterable<Object?>) {
      throw ResolveException(
        node.toSource(),
        'for-element iterable must be Iterable, got '
        '${iterable.runtimeType}',
        location:
            SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
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
            location: SourceSpan.fromAstOffset(
              ctx.source,
              element.offset,
              element.length,
            ),
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
          location: SourceSpan.fromAstOffset(
            ctx.source,
            element.offset,
            element.length,
          ),
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
        location:
            SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
      );
    }
    final target = resolve(targetExpr, ctx);
    final index = resolve(node.index, ctx);

    if (target is List<Object?>) {
      if (index is! int) {
        throw ResolveException(
          node.toSource(),
          'List index must be an int, got ${index.runtimeType}',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        );
      }
      if (index < 0 || index >= target.length) {
        throw ResolveException(
          node.toSource(),
          'Index $index out of range for list of length ${target.length}',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        );
      }
      return target[index];
    }

    if (target is Map<Object?, Object?>) {
      return target[index];
    }

    if (target is MaterialColor) {
      if (index is! int) {
        throw ResolveException(
          node.toSource(),
          'MaterialColor shade index must be an int, got ${index.runtimeType}',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        );
      }
      // MaterialColor.operator[] returns Color? — null when the shade
      // key is not in its internal swatch map. Forward that semantics
      // verbatim so source-level `Colors.grey[42]` yields null rather
      // than throwing.
      return target[index];
    }

    throw ResolveException(
      node.toSource(),
      'Cannot index into ${target.runtimeType}',
      location: SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
    );
  }

  /// Evaluates a [BinaryExpression] — equality (`==`, `!=`), comparison
  /// (`<`, `<=`, `>`, `>=`), short-circuit logical (`&&`, `||`), and
  /// arithmetic (`+`, `-`, `*`, `/`, `%`).
  ///
  /// `&&` / `||` short-circuit per Dart semantics: the RHS is not
  /// evaluated when the LHS determines the result. This preserves the
  /// common null-guard idiom (e.g. `isPresent && item.enabled` where
  /// `item` may be absent when `isPresent` is false).
  ///
  /// `==` / `!=` fall back to Dart's default equality and accept any
  /// type pair. Comparison operators accept `(num, num)` or
  /// `(String, String)`; any other pairing raises [ResolveException].
  /// Arithmetic operators accept `(num, num)` only; string
  /// concatenation via `+` is deliberately unsupported — use string
  /// interpolation instead. `/` always returns `double` per Dart
  /// semantics. Truncating division (`~/`) and bitwise operators are
  /// out of scope and surface via the unsupported-operator default arm.
  Object? _resolveBinary(BinaryExpression node, RuneContext ctx) {
    final op = node.operator.lexeme;

    // Short-circuit: do NOT evaluate rightOperand until we know we must.
    if (op == '&&' || op == '||') {
      final left = resolve(node.leftOperand, ctx);
      if (left is! bool) {
        throw ResolveException(
          node.toSource(),
          'Logical operator "$op" expects bool on the left, '
          'got ${left.runtimeType}',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        );
      }
      if (op == '&&' && !left) return false;
      if (op == '||' && left) return true;
      final right = resolve(node.rightOperand, ctx);
      if (right is! bool) {
        throw ResolveException(
          node.toSource(),
          'Logical operator "$op" expects bool on the right, '
          'got ${right.runtimeType}',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        );
      }
      return right;
    }

    final left = resolve(node.leftOperand, ctx);
    final right = resolve(node.rightOperand, ctx);

    return switch (op) {
      '==' => left == right,
      '!=' => left != right,
      '<' => _compareNumOrString(left, right, node, ctx) < 0,
      '<=' => _compareNumOrString(left, right, node, ctx) <= 0,
      '>' => _compareNumOrString(left, right, node, ctx) > 0,
      '>=' => _compareNumOrString(left, right, node, ctx) >= 0,
      '+' || '-' || '*' || '/' || '%' =>
        _arithmetic(left, right, op, node, ctx),
      _ => throw ResolveException(
          node.toSource(),
          'Unsupported binary operator "$op"',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        ),
    };
  }

  int _compareNumOrString(
    Object? left,
    Object? right,
    BinaryExpression node,
    RuneContext ctx,
  ) {
    if (left is num && right is num) return left.compareTo(right);
    if (left is String && right is String) return left.compareTo(right);
    throw ResolveException(
      node.toSource(),
      'Comparison operator "${node.operator.lexeme}" expects matching num or '
      'String operands; got ${left.runtimeType} and ${right.runtimeType}',
      location:
          SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
    );
  }

  Object _arithmetic(
    Object? left,
    Object? right,
    String op,
    BinaryExpression node,
    RuneContext ctx,
  ) {
    if (left is! num || right is! num) {
      throw ResolveException(
        node.toSource(),
        'Arithmetic operator "$op" expects num operands; got '
        '${left.runtimeType} and ${right.runtimeType}',
        location:
            SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
      );
    }
    return switch (op) {
      '+' => left + right,
      '-' => left - right,
      '*' => left * right,
      '/' => left / right,
      '%' => left % right,
      _ => throw StateError('unreachable: op=$op'),
    };
  }

  /// Evaluates a [PrefixExpression] — logical not (`!`) on `bool` and
  /// unary negation (`-`) on `num`. `++`, `--`, and `~` are out of
  /// scope and raise [ResolveException] via the default arm.
  Object _resolvePrefix(PrefixExpression node, RuneContext ctx) {
    final op = node.operator.lexeme;
    final operand = resolve(node.operand, ctx);
    return switch (op) {
      '!' when operand is bool => !operand,
      '!' => throw ResolveException(
          node.toSource(),
          'Logical not "!" expects bool, got ${operand.runtimeType}',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        ),
      '-' when operand is num => -operand,
      '-' => throw ResolveException(
          node.toSource(),
          'Unary minus "-" expects num, got ${operand.runtimeType}',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        ),
      _ => throw ResolveException(
          node.toSource(),
          'Unsupported prefix operator "$op"',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        ),
    };
  }

  /// Evaluates a [ConditionalExpression] — the ternary `cond ? a : b`.
  ///
  /// Short-circuits the un-taken branch: only the branch selected by the
  /// condition is resolved. This preserves patterns like
  /// `isLoggedIn ? user.name : 'Guest'`, where `user` may be absent from
  /// data when `isLoggedIn` is `false`.
  Object? _resolveConditional(ConditionalExpression node, RuneContext ctx) {
    final cond = resolve(node.condition, ctx);
    if (cond is! bool) {
      throw ResolveException(
        node.toSource(),
        'Conditional expression condition must be bool, got '
        '${cond.runtimeType}',
        location:
            SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
      );
    }
    return resolve(cond ? node.thenExpression : node.elseExpression, ctx);
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
