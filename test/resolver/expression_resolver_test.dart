import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';

import '../_helpers/test_context.dart';

void main() {
  final parser = DartParser();
  ExpressionResolver makeResolver() => ExpressionResolver(LiteralResolver());

  group('ExpressionResolver — dispatch (no InvocationResolver bound)', () {
    test('routes IntegerLiteral → int', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('42'), testContext()), 42);
    });

    test('routes DoubleLiteral → double', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('3.14'), testContext()), 3.14);
    });

    test('routes SimpleStringLiteral → String', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse("'hi'"), testContext()), 'hi');
    });

    test('unwraps ParenthesizedExpression', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('(7)'), testContext()), 7);
    });

    test('resolves ListLiteral element-wise', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('[1, 2, 3]'), testContext()), [1, 2, 3]);
    });

    test('resolves nested ListLiteral', () {
      final r = makeResolver();
      expect(
        r.resolve(parser.parse('[[1, 2], [3]]'), testContext()),
        [
          [1, 2],
          [3],
        ],
      );
    });

    test('throws when InstanceCreation resolved before bind()', () {
      final r = makeResolver();
      expect(
        () => r.resolve(parser.parse("new Text('hi')"), testContext()),
        throwsA(anyOf(isA<StateError>(), isA<ResolveException>())),
      );
    });

    test('throws when MethodInvocation resolved before bind()', () {
      final r = makeResolver();
      expect(
        () => r.resolve(parser.parse("Text('hi')"), testContext()),
        throwsA(anyOf(isA<StateError>(), isA<ResolveException>())),
      );
    });

    test('throws ResolveException on unsupported binary op', () {
      final r = makeResolver();
      expect(
        () => r.resolve(parser.parse('1 + 2'), testContext()),
        throwsA(isA<ResolveException>()),
      );
    });
  });
}
