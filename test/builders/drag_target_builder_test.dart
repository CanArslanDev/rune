import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/drag_target_builder.dart'
    as rdt;
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

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('DragTargetBuilder', () {
    const b = rdt.DragTargetBuilder();

    test('typeName is "DragTarget"', () {
      expect(b.typeName, 'DragTarget');
    });

    test('missing builder raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-closure builder raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'builder': 'nope'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wrong-arity builder raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {'builder': _closureOf("(c, d) => Text('x')")},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('3-arg builder renders returned widget', (tester) async {
      final built = b.build(
        ResolvedArguments(
          named: {
            'builder': _closureOf("(c, cand, rej) => Text('drop-here')"),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      expect(find.byType(DragTarget<Object>), findsOneWidget);
      expect(find.text('drop-here'), findsOneWidget);
    });

    test('onAcceptWithDetails wrong-arity raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'builder': _closureOf("(c, a, b) => Text('x')"),
              'onAcceptWithDetails': _closureOf('() => 1'),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
