import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/data_column_builder.dart';
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
  group('DataColumnBuilder', () {
    const b = DataColumnBuilder();

    test('typeName and constructorName', () {
      expect(b.typeName, 'DataColumn');
      expect(b.constructorName, isNull);
    });

    test('builds with required label', () {
      const label = Text('Name');
      final c = b.build(
        const ResolvedArguments(named: {'label': label}),
        testContext(),
      );
      expect(c, isA<DataColumn>());
      expect(c.label, same(label));
      expect(c.numeric, isFalse);
      expect(c.tooltip, isNull);
      expect(c.onSort, isNull);
    });

    test('numeric and tooltip are forwarded', () {
      final c = b.build(
        const ResolvedArguments(
          named: {
            'label': Text('Age'),
            'numeric': true,
            'tooltip': 'sort by age',
          },
        ),
        testContext(),
      );
      expect(c.numeric, isTrue);
      expect(c.tooltip, 'sort by age');
    });

    test('missing label throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('onSort closure is installed and invokes without error', () {
      final closure = _closureOf('(i, asc) => 0');
      final c = b.build(
        ResolvedArguments(
          named: {'label': const Text('Name'), 'onSort': closure},
        ),
        testContext(),
      );
      expect(c.onSort, isNotNull);
      c.onSort!.call(2, false);
    });

    test('onSort with wrong arity raises ArgumentException', () {
      final closure = _closureOf('(i) => 0');
      expect(
        () => b.build(
          ResolvedArguments(
            named: {'label': const Text('Name'), 'onSort': closure},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('onSort with non-closure source raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'label': Text('Name'), 'onSort': 'eventName'},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
