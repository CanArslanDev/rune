import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/dismissible_builder.dart';
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

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('DismissibleBuilder', () {
    const b = DismissibleBuilder();

    test('typeName is "Dismissible"', () {
      expect(b.typeName, 'Dismissible');
    });

    testWidgets('renders child under a required key', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'key': ValueKey<Object>('row-1'),
            'child': Text('swipe-me'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      expect(find.byType(Dismissible), findsOneWidget);
      expect(find.text('swipe-me'), findsOneWidget);
    });

    test('missing key raises ArgumentException citing Dismissible', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'child': Text('x')},
          ),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>()
              .having((e) => e.source, 'source', 'Dismissible'),
        ),
      );
    });

    testWidgets('direction defaults to horizontal', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'key': ValueKey<Object>('r'),
            'child': Text('x'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      final w = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(w.direction, DismissDirection.horizontal);
    });

    testWidgets('direction override routes through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'key': ValueKey<Object>('r'),
            'child': Text('x'),
            'direction': DismissDirection.endToStart,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      final w = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(w.direction, DismissDirection.endToStart);
    });

    testWidgets('onDismissed closure attaches', (tester) async {
      final built = b.build(
        ResolvedArguments(
          named: {
            'key': const ValueKey<Object>('r'),
            'child': const Text('x'),
            'onDismissed': _closureOf('(dir) => 1'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      final w = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(w.onDismissed, isNotNull);
    });
  });
}
