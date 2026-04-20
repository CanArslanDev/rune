import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/expansion_panel_list_builder.dart';
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

ExpansionPanel _panel() => ExpansionPanel(
      headerBuilder: (_, __) => const Text('h'),
      body: const Text('b'),
    );

void main() {
  group('ExpansionPanelListBuilder', () {
    const b = ExpansionPanelListBuilder();

    test('typeName is "ExpansionPanelList"', () {
      expect(b.typeName, 'ExpansionPanelList');
    });

    test('builds with children list and applies defaults', () {
      final panel = _panel();
      final w = b.build(
        ResolvedArguments(
          named: {
            'children': <Object?>[panel],
          },
        ),
        testContext(),
      ) as ExpansionPanelList;
      expect(w.children, hasLength(1));
      expect(w.expansionCallback, isNull);
    });

    test('non-ExpansionPanel entries are filtered', () {
      final panel = _panel();
      final w = b.build(
        ResolvedArguments(
          named: {
            'children': <Object?>[panel, 'bogus', 99],
          },
        ),
        testContext(),
      ) as ExpansionPanelList;
      expect(w.children, hasLength(1));
    });

    test('missing children raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('expansionCallback closure is installed', () {
      final panel = _panel();
      final w = b.build(
        ResolvedArguments(
          named: {
            'children': <Object?>[panel],
            'expansionCallback': _closureOf('(i, e) => 0'),
          },
        ),
        testContext(),
      ) as ExpansionPanelList;
      expect(w.expansionCallback, isNotNull);
      w.expansionCallback!.call(0, true);
    });

    test('expansionCallback with wrong arity raises ArgumentException', () {
      final panel = _panel();
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'children': <Object?>[panel],
              'expansionCallback': _closureOf('(i) => 0'),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
