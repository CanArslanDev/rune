import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';

import '../_helpers/test_context.dart';

void main() {
  final parser = DartParser();
  final resolver = IdentifierResolver();

  group('IdentifierResolver — SimpleIdentifier (data lookup)', () {
    test('returns value from data context', () {
      final ctx = testContext(
        data: RuneDataContext(const {'userName': 'Ali', 'count': 42}),
      );
      final e = parser.parse('userName') as SimpleIdentifier;
      expect(resolver.resolveSimple(e, ctx), 'Ali');
    });

    test('preserves non-string types', () {
      final ctx = testContext(data: RuneDataContext(const {'count': 42}));
      final e = parser.parse('count') as SimpleIdentifier;
      expect(resolver.resolveSimple(e, ctx), 42);
    });

    test('returns null when the value is explicitly null', () {
      final ctx = testContext(data: RuneDataContext(const {'x': null}));
      final e = parser.parse('x') as SimpleIdentifier;
      expect(resolver.resolveSimple(e, ctx), isNull);
    });

    test('throws BindingException when the key is missing', () {
      final ctx = testContext();
      final e = parser.parse('missing') as SimpleIdentifier;
      expect(
        () => resolver.resolveSimple(e, ctx),
        throwsA(
          isA<BindingException>()
              .having((err) => err.message, 'message', contains('missing')),
        ),
      );
    });
  });

  group('IdentifierResolver — PrefixedIdentifier (constants)', () {
    test('resolves Colors.red from constants', () {
      final constants = ConstantRegistry()
        ..register('Colors', 'red', Colors.red);
      final ctx = testContext(constants: constants);
      final e = parser.parse('Colors.red') as PrefixedIdentifier;
      expect(resolver.resolvePrefixed(e, ctx), Colors.red);
    });

    test('resolves MainAxisAlignment.center', () {
      final constants = ConstantRegistry()
        ..register('MainAxisAlignment', 'center', MainAxisAlignment.center);
      final ctx = testContext(constants: constants);
      final e =
          parser.parse('MainAxisAlignment.center') as PrefixedIdentifier;
      expect(resolver.resolvePrefixed(e, ctx), MainAxisAlignment.center);
    });

    test('throws ResolveException when the member is unknown', () {
      final ctx = testContext();
      final e = parser.parse('Colors.nope') as PrefixedIdentifier;
      expect(
        () => resolver.resolvePrefixed(e, ctx),
        throwsA(
          isA<ResolveException>()
              .having((err) => err.source, 'source', 'Colors.nope'),
        ),
      );
    });
  });
}
