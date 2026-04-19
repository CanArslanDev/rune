import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_scope.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';
import 'package:rune/src/resolver/statement_resolver.dart';

import '../_helpers/test_context.dart';

/// Parses a raw block-body closure `(params) { stmts }` source string and
/// returns the list of [Statement]s inside the body plus a matching
/// pipeline, ready to drive [StatementResolver.execute].
({
  List<Statement> statements,
  ExpressionResolver expr,
  StatementResolver stmt,
}) _parseBlock(DartParser parser, String source) {
  final node = parser.parse(source);
  expect(node, isA<FunctionExpression>());
  final fn = node as FunctionExpression;
  expect(fn.body, isA<BlockFunctionBody>());
  final body = fn.body as BlockFunctionBody;
  final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
  expr.bindProperty(PropertyResolver(expr));
  final stmt = StatementResolver(expr);
  return (statements: body.block.statements.toList(), expr: expr, stmt: stmt);
}

void main() {
  final parser = DartParser();

  group('StatementResolver - ExpressionStatement', () {
    test('discards the result of its expression', () {
      final p = _parseBlock(parser, '() { 1 + 2; }');
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      final r = p.stmt.execute(p.statements, ctx);
      expect(r.returned, isFalse);
      expect(r.returnValue, isNull);
    });
  });

  group('StatementResolver - ReturnStatement', () {
    test('return expr short-circuits the list and yields the value', () {
      final p = _parseBlock(parser, '() { return 42; 9999; }');
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      final r = p.stmt.execute(p.statements, ctx);
      expect(r.returned, isTrue);
      expect(r.returnValue, 42);
    });

    test('bare `return;` short-circuits and yields null', () {
      final p = _parseBlock(parser, '() { return; }');
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      final r = p.stmt.execute(p.statements, ctx);
      expect(r.returned, isTrue);
      expect(r.returnValue, isNull);
    });
  });

  group('StatementResolver - VariableDeclarationStatement', () {
    test('var x = 5; declares and binds in scope', () {
      final p = _parseBlock(parser, '() { var x = 5; }');
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      p.stmt.execute(p.statements, ctx);
      expect(scope.lookup('x'), 5);
    });

    test('var x; declares and binds to null in scope', () {
      final p = _parseBlock(parser, '() { var x; }');
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      p.stmt.execute(p.statements, ctx);
      expect(scope.has('x'), isTrue);
      expect(scope.lookup('x'), isNull);
    });

    test('var a = 1, b = 2; declares both in one statement', () {
      final p = _parseBlock(parser, '() { var a = 1, b = 2; }');
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      p.stmt.execute(p.statements, ctx);
      expect(scope.lookup('a'), 1);
      expect(scope.lookup('b'), 2);
    });

    test('final x = 5; declares the name in scope', () {
      // Rune's source-level `final` is informational only in Phase B;
      // runtime enforcement may arrive later. Declaration works.
      final p = _parseBlock(parser, '() { final x = 5; }');
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      p.stmt.execute(p.statements, ctx);
      expect(scope.lookup('x'), 5);
    });
  });

  group('StatementResolver - IfStatement', () {
    test('true condition executes then-branch', () {
      final p = _parseBlock(
        parser,
        '() { if (true) { return 1; } return 2; }',
      );
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      final r = p.stmt.execute(p.statements, ctx);
      expect(r.returnValue, 1);
    });

    test('false condition executes else-branch', () {
      final p = _parseBlock(
        parser,
        '() { if (false) { return 1; } else { return 2; } }',
      );
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      final r = p.stmt.execute(p.statements, ctx);
      expect(r.returnValue, 2);
    });

    test('false condition with no else falls through', () {
      final p = _parseBlock(
        parser,
        '() { if (false) { return 1; } return 99; }',
      );
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      final r = p.stmt.execute(p.statements, ctx);
      expect(r.returnValue, 99);
    });

    test('non-bool condition raises ResolveException', () {
      final p = _parseBlock(
        parser,
        "() { if ('x') { return 1; } return 2; }",
      );
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      try {
        p.stmt.execute(p.statements, ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('bool'));
      }
    });
  });

  group('StatementResolver - AssignmentExpression statement', () {
    test('reassigns a previously-declared local via ExpressionStatement', () {
      // `var x = 5; x = 10;` - after execution, scope.lookup('x') == 10.
      final p = _parseBlock(parser, '() { var x = 5; x = 10; }');
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      p.stmt.execute(p.statements, ctx);
      expect(scope.lookup('x'), 10);
    });

    test('assign to undeclared name raises BindingException', () {
      final p = _parseBlock(parser, '() { ghost = 5; }');
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      expect(
        () => p.stmt.execute(p.statements, ctx),
        throwsA(isA<BindingException>()),
      );
    });

    test('assign to a ctx.data key raises ReadOnly ResolveException', () {
      final p = _parseBlock(parser, '() { hostVar = 5; }');
      final scope = RuneScope();
      final ctx = testContext(
        data: RuneDataContext(const {'hostVar': 42}),
      ).copyWith(scope: scope);
      try {
        p.stmt.execute(p.statements, ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('read-only'));
        expect(e.message, contains('hostVar'));
      }
    });
  });

  group('StatementResolver - unsupported statements', () {
    test('WhileStatement raises ResolveException', () {
      final p = _parseBlock(parser, '() { while (true) { 1; } }');
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      try {
        p.stmt.execute(p.statements, ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('Unsupported statement'));
      }
    });
  });

  group('StatementResolver - nested Block creates a child scope', () {
    test('variables declared in inner block do not leak to the outer one',
        () {
      // Outer block has a top-level `x`, inner block also declares
      // `x` - the inner declaration is a child-scope shadow, not a
      // re-declaration.
      final p = _parseBlock(
        parser,
        '() { var x = 1; { var x = 99; } return x; }',
      );
      final scope = RuneScope();
      final ctx = testContext().copyWith(scope: scope);
      final r = p.stmt.execute(p.statements, ctx);
      expect(r.returnValue, 1);
    });
  });
}
