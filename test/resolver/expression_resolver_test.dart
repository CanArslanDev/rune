import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';

import '../_helpers/test_context.dart';

void main() {
  final parser = DartParser();
  ExpressionResolver makeResolver() =>
      ExpressionResolver(LiteralResolver(), IdentifierResolver());

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

    test('routes SimpleIdentifier → data context', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(data: RuneDataContext(const {'name': 'Ali'}));
      expect(r.resolve(parser.parse('name'), ctx), 'Ali');
    });

    test('routes PrefixedIdentifier → constants', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final constants = ConstantRegistry()..register('Colors', 'red', 0xFFFF0000);
      final ctx = testContext(constants: constants);
      expect(r.resolve(parser.parse('Colors.red'), ctx), 0xFFFF0000);
    });

    test('resolves SetOrMapLiteral as a Set when element-only', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      expect(r.resolve(parser.parse('{1, 2, 3}'), testContext()), {1, 2, 3});
    });

    test('resolves SetOrMapLiteral as a Map when entries are present', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      expect(
        r.resolve(parser.parse("{'a': 1, 'b': 2}"), testContext()),
        {'a': 1, 'b': 2},
      );
    });

    test('resolves StringInterpolation with a literal expression', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      expect(
        r.resolve(parser.parse(r"'answer: ${42}'"), testContext()),
        'answer: 42',
      );
    });

    test('resolves StringInterpolation with an identifier reference', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(data: RuneDataContext(const {'name': 'Ali'}));
      expect(r.resolve(parser.parse(r"'hello $name'"), ctx), 'hello Ali');
    });
  });
}
