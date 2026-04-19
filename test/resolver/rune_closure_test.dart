import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';
import 'package:rune/src/resolver/statement_resolver.dart';

import '../_helpers/test_context.dart';

/// Drives the parser to produce a [FunctionExpression] AST node from a
/// raw closure source string. The parser wraps everything in
/// `dynamic __rune__ = <source>;`, so a closure source like `(x) => x`
/// arrives here as a [FunctionExpression].
FunctionExpression _parseFn(DartParser parser, String source) {
  final expr = parser.parse(source);
  expect(
    expr,
    isA<FunctionExpression>(),
    reason: 'expected parser.parse("$source") to produce FunctionExpression',
  );
  return expr as FunctionExpression;
}

/// Shared pipeline factory. Mirrors the style of other resolver tests.
/// Wires property resolver so closure bodies exercising property access
/// can resolve.
ExpressionResolver _makeResolver() {
  final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
  r.bindProperty(PropertyResolver(r));
  return r;
}

void main() {
  final parser = DartParser();

  group('RuneClosure.expression (arrow-body) construction and fields', () {
    test('round-trips constructor arguments', () {
      final fn = _parseFn(parser, '(x) => x');
      final body = (fn.body as ExpressionFunctionBody).expression;
      final resolver = _makeResolver();
      final ctx = testContext();

      final closure = RuneClosure.expression(
        parameterNames: const ['x'],
        body: body,
        capturedContext: ctx,
        resolver: resolver,
      );

      expect(closure.parameterNames, ['x']);
      expect(closure.body, same(body));
      expect(closure.bodyBlock, isNull);
      expect(closure.capturedContext, same(ctx));
      expect(closure.resolver, same(resolver));
      expect(closure.statementResolver, isNull);
    });
  });

  group('RuneClosure.expression invocation', () {
    test('no-param closure body "42" returns 42', () {
      final fn = _parseFn(parser, '() => 42');
      final body = (fn.body as ExpressionFunctionBody).expression;
      final resolver = _makeResolver();

      final closure = RuneClosure.expression(
        parameterNames: const <String>[],
        body: body,
        capturedContext: testContext(),
        resolver: resolver,
      );

      expect(closure.call(const <Object?>[]), 42);
    });

    test('one-param closure "(x) => x + 1" returns x + 1', () {
      final fn = _parseFn(parser, '(x) => x + 1');
      final body = (fn.body as ExpressionFunctionBody).expression;
      final resolver = _makeResolver();

      final closure = RuneClosure.expression(
        parameterNames: const ['x'],
        body: body,
        capturedContext: testContext(),
        resolver: resolver,
      );

      expect(closure.call(const <Object?>[5]), 6);
    });

    test('two-param closure "(x, y) => x * y" returns x * y', () {
      final fn = _parseFn(parser, '(x, y) => x * y');
      final body = (fn.body as ExpressionFunctionBody).expression;
      final resolver = _makeResolver();

      final closure = RuneClosure.expression(
        parameterNames: const ['x', 'y'],
        body: body,
        capturedContext: testContext(),
        resolver: resolver,
      );

      expect(closure.call(const <Object?>[2, 3]), 6);
    });
  });

  group('RuneClosure.expression arity mismatch', () {
    test('too many args throws ResolveException naming expected count', () {
      final fn = _parseFn(parser, '(x) => x');
      final body = (fn.body as ExpressionFunctionBody).expression;
      final closure = RuneClosure.expression(
        parameterNames: const ['x'],
        body: body,
        capturedContext: testContext(),
        resolver: _makeResolver(),
      );

      try {
        closure.call(const <Object?>[1, 2]);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('arity'));
        expect(e.message, contains('expected 1'));
        expect(e.message, contains('got 2'));
      }
    });

    test('too few args throws ResolveException naming expected count', () {
      final fn = _parseFn(parser, '(x) => x');
      final body = (fn.body as ExpressionFunctionBody).expression;
      final closure = RuneClosure.expression(
        parameterNames: const ['x'],
        body: body,
        capturedContext: testContext(),
        resolver: _makeResolver(),
      );

      try {
        closure.call(const <Object?>[]);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('arity'));
        expect(e.message, contains('expected 1'));
        expect(e.message, contains('got 0'));
      }
    });
  });

  group('RuneClosure.expression captured context and binding order', () {
    test('body can reach captured data', () {
      final fn = _parseFn(parser, '(x) => x + y');
      final body = (fn.body as ExpressionFunctionBody).expression;
      final ctx = testContext(
        data: RuneDataContext(const {'y': 10}),
      );
      final closure = RuneClosure.expression(
        parameterNames: const ['x'],
        body: body,
        capturedContext: ctx,
        resolver: _makeResolver(),
      );

      expect(closure.call(const <Object?>[5]), 15);
    });

    test('argument binding shadows captured data of the same name', () {
      final fn = _parseFn(parser, '(x) => x');
      final body = (fn.body as ExpressionFunctionBody).expression;
      final ctx = testContext(
        // capturedContext has x=999; argument is 42; argument must win.
        data: RuneDataContext(const {'x': 999}),
      );
      final closure = RuneClosure.expression(
        parameterNames: const ['x'],
        body: body,
        capturedContext: ctx,
        resolver: _makeResolver(),
      );

      expect(closure.call(const <Object?>[42]), 42);
    });
  });

  group('RuneClosure diagnostics', () {
    test('toString includes parameter list and body source', () {
      final fn = _parseFn(parser, '(x, y) => x + y');
      final body = (fn.body as ExpressionFunctionBody).expression;
      final closure = RuneClosure.expression(
        parameterNames: const ['x', 'y'],
        body: body,
        capturedContext: testContext(),
        resolver: _makeResolver(),
      );

      final s = closure.toString();
      expect(s, contains('x'));
      expect(s, contains('y'));
      expect(s, contains('x + y'));
    });
  });

  group('RuneClosure.block (block-body) invocation', () {
    test('block body with no explicit return returns null', () {
      final fn = _parseFn(parser, '() { var x = 1; }');
      final body = (fn.body as BlockFunctionBody).block;
      final resolver = _makeResolver();
      final statements = StatementResolver(resolver);
      final closure = RuneClosure.block(
        parameterNames: const <String>[],
        bodyBlock: body,
        capturedContext: testContext(),
        resolver: resolver,
        statementResolver: statements,
      );

      expect(closure.call(const <Object?>[]), isNull);
    });

    test('block body with explicit return yields the returned value', () {
      final fn = _parseFn(parser, '(x) { return x + 1; }');
      final body = (fn.body as BlockFunctionBody).block;
      final resolver = _makeResolver();
      final statements = StatementResolver(resolver);
      final closure = RuneClosure.block(
        parameterNames: const ['x'],
        bodyBlock: body,
        capturedContext: testContext(),
        resolver: resolver,
        statementResolver: statements,
      );

      expect(closure.call(const <Object?>[41]), 42);
    });

    test('block body with declared-and-returned local computes correctly',
        () {
      final fn = _parseFn(parser, '(x) { final y = x * 2; return y + 1; }');
      final body = (fn.body as BlockFunctionBody).block;
      final resolver = _makeResolver();
      final statements = StatementResolver(resolver);
      final closure = RuneClosure.block(
        parameterNames: const ['x'],
        bodyBlock: body,
        capturedContext: testContext(),
        resolver: resolver,
        statementResolver: statements,
      );

      expect(closure.call(const <Object?>[5]), 11);
    });

    test('block body with nested if controlling the return value', () {
      final fn = _parseFn(
        parser,
        '(n) { if (n > 0) { return "pos"; } return "neg"; }',
      );
      final body = (fn.body as BlockFunctionBody).block;
      final resolver = _makeResolver();
      final statements = StatementResolver(resolver);
      final closure = RuneClosure.block(
        parameterNames: const ['n'],
        bodyBlock: body,
        capturedContext: testContext(),
        resolver: resolver,
        statementResolver: statements,
      );

      expect(closure.call(const <Object?>[5]), 'pos');
      expect(closure.call(const <Object?>[-3]), 'neg');
    });
  });
}
