import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/page_route_builder_builder.dart';
import 'package:rune/src/builders/widgets/text_builder.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/widget_registry.dart';
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
  final widgets = WidgetRegistry()..registerBuilder(const TextBuilder());
  return RuneClosure.expression(
    parameterNames: paramNames,
    body: body,
    capturedContext: testContext(widgets: widgets),
    resolver: expr,
  );
}

void main() {
  group('PageRouteBuilderBuilder', () {
    const b = PageRouteBuilderBuilder();

    test('typeName / constructorName', () {
      expect(b.typeName, 'PageRouteBuilder');
      expect(b.constructorName, isNull);
    });

    test('missing pageBuilder raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wrong-arity pageBuilder raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {'pageBuilder': _closureOf("(c) => Text('x')")},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('defaults: transitionDuration=300ms, barrierDismissible=false', () {
      final route = b.build(
        ResolvedArguments(
          named: {
            'pageBuilder':
                _closureOf("(c, a, s) => Text('x')"),
          },
        ),
        testContext(),
      );
      expect(route.transitionDuration, const Duration(milliseconds: 300));
      expect(
        route.reverseTransitionDuration,
        const Duration(milliseconds: 300),
      );
      expect(route.barrierDismissible, isFalse);
    });

    test('transitionDuration / reverseTransitionDuration plumb through', () {
      final route = b.build(
        ResolvedArguments(
          named: {
            'pageBuilder': _closureOf("(c, a, s) => Text('x')"),
            'transitionDuration': const Duration(milliseconds: 120),
            'reverseTransitionDuration': const Duration(milliseconds: 80),
            'barrierDismissible': true,
          },
        ),
        testContext(),
      );
      expect(route.transitionDuration, const Duration(milliseconds: 120));
      expect(route.reverseTransitionDuration, const Duration(milliseconds: 80));
      expect(route.barrierDismissible, isTrue);
    });

    test('transitionsBuilder arity mismatch raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'pageBuilder': _closureOf("(c, a, s) => Text('x')"),
              'transitionsBuilder':
                  _closureOf("(c, a) => Text('y')"),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('pushes and renders via Navigator', (tester) async {
      final route = b.build(
        ResolvedArguments(
          named: {
            'pageBuilder': _closureOf("(c, a, s) => Text('Pushed')"),
            'transitionDuration': const Duration(milliseconds: 10),
            'reverseTransitionDuration': const Duration(milliseconds: 10),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => Navigator.of(ctx).push(route),
              child: const Text('Go'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.text('Pushed'), findsOneWidget);
    });
  });
}
