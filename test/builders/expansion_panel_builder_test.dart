import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/expansion_panel_builder.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

import '../_helpers/test_context.dart';

RuneClosure _closureOf(String source) {
  final parser = DartParser();
  final fn = parser.parse(source) as FunctionExpression;
  final body = (fn.body as ExpressionFunctionBody).expression;
  final paramNames = <String>[];
  final parameterList = fn.parameters;
  if (parameterList != null) {
    for (final param in parameterList.parameters) {
      final nameToken = param.name;
      if (nameToken != null) paramNames.add(nameToken.lexeme);
    }
  }
  final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
  expr
    ..bindProperty(PropertyResolver(expr))
    ..bind(InvocationResolver(expr));
  return RuneClosure.expression(
    parameterNames: paramNames,
    body: body,
    capturedContext: testContext(),
    resolver: expr,
  );
}

void main() {
  group('ExpansionPanelBuilder', () {
    const b = ExpansionPanelBuilder();

    test('typeName and constructorName', () {
      expect(b.typeName, 'ExpansionPanel');
      expect(b.constructorName, isNull);
    });

    test('builds with required body and headerBuilder closure', () {
      final panel = b.build(
        ResolvedArguments(
          named: {
            'body': const Text('body'),
            'headerBuilder': _closureOf("(c, e) => Text('hdr')"),
          },
        ),
        testContext(),
      );
      expect(panel, isA<ExpansionPanel>());
      expect(panel.isExpanded, isFalse);
      expect(panel.canTapOnHeader, isFalse);
    });

    test('isExpanded and canTapOnHeader honoured', () {
      final panel = b.build(
        ResolvedArguments(
          named: {
            'body': const Text('body'),
            'headerBuilder': _closureOf("(c, e) => Text('hdr')"),
            'isExpanded': true,
            'canTapOnHeader': true,
          },
        ),
        testContext(),
      );
      expect(panel.isExpanded, isTrue);
      expect(panel.canTapOnHeader, isTrue);
    });

    test('missing body raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'headerBuilder': _closureOf("(c, e) => Text('h')"),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing headerBuilder raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'body': Text('body')}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('headerBuilder with wrong arity raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'body': const Text('body'),
              'headerBuilder': _closureOf("(c) => Text('h')"),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
