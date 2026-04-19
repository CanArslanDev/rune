import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/extension_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';

import '../_helpers/test_context.dart';

void main() {
  final parser = DartParser();

  ExpressionResolver buildExprResolver() {
    final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
    final prop = PropertyResolver(expr);
    expr.bindProperty(prop);
    return expr;
  }

  group('PropertyResolver', () {
    test('resolves integer-literal extension (10.px)', () {
      final exprResolver = buildExprResolver();
      final resolver = PropertyResolver(exprResolver);
      final extensions = ExtensionRegistry()
        ..register('px', (target, ctx) => (target! as num).toDouble());
      final ctx = testContext(extensions: extensions);
      final node = parser.parse('10.px') as PropertyAccess;
      expect(resolver.resolve(node, ctx), 10.0);
    });

    test('passes the resolved target to the handler', () {
      final exprResolver = buildExprResolver();
      final resolver = PropertyResolver(exprResolver);
      Object? seen;
      final extensions = ExtensionRegistry()
        ..register('captureTarget', (target, ctx) {
          seen = target;
          return target;
        });
      final ctx = testContext(extensions: extensions);
      final node = parser.parse('42.captureTarget') as PropertyAccess;
      resolver.resolve(node, ctx);
      expect(seen, 42);
    });

    test('passes the context to the handler', () {
      final exprResolver = buildExprResolver();
      final resolver = PropertyResolver(exprResolver);
      final extensions = ExtensionRegistry()
        ..register('ctx', (t, c) => c);
      final ctx = testContext(extensions: extensions);
      final node = parser.parse('1.ctx') as PropertyAccess;
      expect(resolver.resolve(node, ctx), same(ctx));
    });

    test('resolves parenthesized literal (5).doubled', () {
      final exprResolver = buildExprResolver();
      final resolver = PropertyResolver(exprResolver);
      final extensions = ExtensionRegistry()
        ..register('doubled', (target, ctx) => (target! as num) * 2);
      final ctx = testContext(extensions: extensions);
      final node = parser.parse('(5).doubled') as PropertyAccess;
      expect(resolver.resolve(node, ctx), 10);
    });

    test('unknown property throws ResolveException citing source', () {
      final exprResolver = buildExprResolver();
      final resolver = PropertyResolver(exprResolver);
      final ctx = testContext();
      final node = parser.parse('(1).nope') as PropertyAccess;
      expect(
        () => resolver.resolve(node, ctx),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.source, 'source', '(1).nope')
              .having((e) => e.message, 'message', contains('nope')),
        ),
      );
    });

    test('map target: resolves key from data map', () {
      final exprResolver = buildExprResolver();
      final resolver = PropertyResolver(exprResolver);
      final ctx = testContext(
        data: RuneDataContext(const {
          'user': {
            'profile': {'name': 'Ali', 'age': 30},
          },
        }),
      );
      final node = parser.parse('user.profile.name') as PropertyAccess;
      expect(resolver.resolve(node, ctx), 'Ali');
    });

    test('map target: missing key returns null (no exception)', () {
      final exprResolver = buildExprResolver();
      final resolver = PropertyResolver(exprResolver);
      final ctx = testContext(
        data: RuneDataContext(const {
          'user': {
            'profile': {'name': 'Ali'},
          },
        }),
      );
      final node = parser.parse('user.profile.age') as PropertyAccess;
      expect(resolver.resolve(node, ctx), isNull);
    });

    test('map target wins over extension of the same name', () {
      final exprResolver = buildExprResolver();
      final resolver = PropertyResolver(exprResolver);
      final extensions = ExtensionRegistry()
        ..register('name', (t, c) => 'from-extension');
      final ctx = testContext(
        data: RuneDataContext(const {
          'user': {
            'profile': {'name': 'from-data'},
          },
        }),
        extensions: extensions,
      );
      final node = parser.parse('user.profile.name') as PropertyAccess;
      expect(
        resolver.resolve(node, ctx),
        'from-data',
        reason: 'map wins on conflict; data always beats extensions',
      );
    });

    test('non-map target with unknown extension still throws', () {
      final exprResolver = buildExprResolver();
      final resolver = PropertyResolver(exprResolver);
      final ctx = testContext();
      final node = parser.parse('(1).nope') as PropertyAccess;
      expect(
        () => resolver.resolve(node, ctx),
        throwsA(isA<ResolveException>()),
      );
    });
  });

  group('PropertyResolver — ResolveException.location threading', () {
    test(
      'unknown extension property populates location with line/excerpt',
      () {
        final exprResolver = buildExprResolver();
        final resolver = PropertyResolver(exprResolver);
        const source = '(1).nope';
        final ctx = testContext(source: source);
        final node = parser.parse(source) as PropertyAccess;
        try {
          resolver.resolve(node, ctx);
          fail('expected ResolveException');
        } on ResolveException catch (err) {
          expect(err.location, isNotNull);
          expect(err.location!.line, 1);
          expect(err.location!.column, 1);
          expect(err.location!.excerpt, '(1).nope');
        }
      },
    );
  });
}
