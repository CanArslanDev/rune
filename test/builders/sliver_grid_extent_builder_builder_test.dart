import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/sliver_grid_extent_builder_builder.dart';
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

Widget _wrapSliver(Widget sliver) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 400,
          child: CustomScrollView(slivers: [sliver]),
        ),
      ),
    );

void main() {
  group('SliverGridExtentBuilderBuilder', () {
    const b = SliverGridExtentBuilderBuilder();

    test('typeName + constructorName', () {
      expect(b.typeName, 'SliverGrid');
      expect(b.constructorName, 'extentBuilder');
    });

    test('missing maxCrossAxisExtent throws ArgumentException', () {
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
          const ResolvedArguments(named: {'maxCrossAxisExtent': 200}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-closure itemBuilder throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'maxCrossAxisExtent': 200, 'itemBuilder': 7},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('happy path renders grid cells', (tester) async {
      final sliver = b.build(
        ResolvedArguments(
          named: {
            'maxCrossAxisExtent': 200,
            'itemCount': 3,
            'itemBuilder': _closureOf("(c, i) => Text('tile')"),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrapSliver(sliver));
      expect(find.text('tile'), findsWidgets);
    });
  });
}
