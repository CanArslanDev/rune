import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/grid_view_count_builder_builder.dart';
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

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SizedBox(height: 400, child: child)),
    );

void main() {
  group('GridViewCountBuilderBuilder', () {
    const b = GridViewCountBuilderBuilder();

    test('typeName + constructorName', () {
      expect(b.typeName, 'GridView');
      expect(b.constructorName, 'countBuilder');
    });

    test('missing crossAxisCount throws ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {'itemBuilder': _closureOf("(c, i) => Text('x')")},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing itemBuilder throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'crossAxisCount': 2}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-closure itemBuilder throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'crossAxisCount': 2, 'itemBuilder': 7},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('happy path renders grid cells', (tester) async {
      final widget = b.build(
        ResolvedArguments(
          named: {
            'crossAxisCount': 2,
            'itemCount': 4,
            'itemBuilder': _closureOf("(c, i) => Text('cell')"),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(widget));
      expect(find.text('cell'), findsWidgets);
    });
  });
}
