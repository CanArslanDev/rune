import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
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
    return ExpressionResolver(LiteralResolver(), IdentifierResolver());
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
  });
}
