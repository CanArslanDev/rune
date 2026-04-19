import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/extension_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';

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
      final constants = ConstantRegistry()
        ..register('Colors', 'red', 0xFFFF0000);
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

    test('routes PropertyAccess → PropertyResolver', () {
      final shared =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final prop = PropertyResolver(shared);
      shared.bindProperty(prop);
      final extensions = ExtensionRegistry()
        ..register('pct', (t, c) => (t! as num) / 100);
      final ctx = testContext(extensions: extensions);
      expect(shared.resolve(parser.parse('(50).pct'), ctx), 0.5);
    });

    test('PropertyAccess without bindProperty throws', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      expect(
        () => r.resolve(parser.parse('(1).x'), testContext()),
        throwsA(anyOf(isA<StateError>(), isA<ResolveException>())),
      );
    });

    test('IndexExpression on List returns the indexed element', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': ['a', 'b', 'c'],
        }),
      );
      expect(r.resolve(parser.parse('items[0]'), ctx), 'a');
      expect(r.resolve(parser.parse('items[2]'), ctx), 'c');
    });

    test('IndexExpression with nested Map element', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': [
            {'title': 'first'},
            {'title': 'second'},
          ],
        }),
      );
      expect(
        r.resolve(parser.parse('items[1]'), ctx),
        const {'title': 'second'},
      );
    });

    test('IndexExpression on Map returns the keyed value', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'prices': {'apple': 1, 'banana': 2},
        }),
      );
      expect(r.resolve(parser.parse("prices['apple']"), ctx), 1);
      expect(r.resolve(parser.parse("prices['banana']"), ctx), 2);
    });

    test('IndexExpression on List with out-of-range index throws', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': ['a'],
        }),
      );
      expect(
        () => r.resolve(parser.parse('items[5]'), ctx),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('range')),
        ),
      );
    });

    test('IndexExpression on non-list/map throws', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {'scalar': 42}),
      );
      expect(
        () => r.resolve(parser.parse('scalar[0]'), ctx),
        throwsA(isA<ResolveException>()),
      );
    });

    test('for-element expands over an iterable', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': ['a', 'b', 'c'],
        }),
      );
      expect(
        r.resolve(parser.parse('[for (final x in items) x]'), ctx),
        ['a', 'b', 'c'],
      );
    });

    test('for-element binds the loop variable into data context', () {
      final shared = ExpressionResolver(
        LiteralResolver(),
        IdentifierResolver(),
      );
      shared.bindProperty(PropertyResolver(shared));
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': [
            {'title': 'first'},
            {'title': 'second'},
          ],
        }),
      );
      expect(
        shared.resolve(
          parser.parse('[for (final item in items) item.title]'),
          ctx,
        ),
        ['first', 'second'],
      );
    });

    test('for-element iterable of wrong type throws', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {'notIterable': 42}),
      );
      expect(
        () => r.resolve(
          parser.parse('[for (final x in notIterable) x]'),
          ctx,
        ),
        throwsA(
          isA<ResolveException>().having(
            (e) => e.message,
            'message',
            contains('Iterable'),
          ),
        ),
      );
    });

    test('for-element preserves static elements around it', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': [1, 2],
        }),
      );
      expect(
        r.resolve(
          parser.parse('[0, for (final x in items) x, 99]'),
          ctx,
        ),
        [0, 1, 2, 99],
      );
    });

    test('nested for-elements compose', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'rows': [
            [1, 2],
            [3, 4],
          ],
        }),
      );
      expect(
        r.resolve(
          parser.parse(
            '[for (final row in rows) for (final cell in row) cell]',
          ),
          ctx,
        ),
        [1, 2, 3, 4],
      );
    });
  });

  group('ExpressionResolver — ResolveException.location threading', () {
    test('unsupported expression populates location with line/excerpt', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      // `1 + 2` is a BinaryExpression — not handled by the resolver's
      // switch arms, so it hits the `_` default that throws
      // ResolveException with the span of the unsupported node.
      const source = '1 + 2';
      final ctx = testContext(source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.location, isNotNull);
        expect(e.location!.line, 1);
        expect(e.location!.column, 1);
        expect(e.location!.excerpt, '1 + 2');
      }
    });

    test('for-element with wrong parts shape populates location', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      // c-style `for (var i = 0; i < 3; i++) i` is ForPartsWithDeclarations,
      // not ForEachPartsWithDeclaration, so it triggers the guard.
      const source = '[for (var i = 0; i < 3; i++) i]';
      final ctx = testContext(source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.location, isNotNull);
        expect(e.location!.line, 1);
        // The ForElement node's offset is right after the opening '['.
        expect(e.location!.column, 2);
        expect(e.location!.excerpt, source);
      }
    });
  });
}
