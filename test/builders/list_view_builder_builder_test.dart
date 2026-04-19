import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/list_view_builder_builder.dart';
import 'package:rune/src/builders/widgets/text_builder.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/widget_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

import '../_helpers/test_context.dart';

RuneClosure _closureOf(String source, {RuneContext? ctx}) {
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
  final capturedCtx = ctx ?? testContext(widgets: widgets);
  return RuneClosure.expression(
    parameterNames: paramNames,
    body: body,
    capturedContext: capturedCtx,
    resolver: expr,
  );
}

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SizedBox(height: 400, child: child)),
    );

void main() {
  group('ListViewBuilderBuilder', () {
    const b = ListViewBuilderBuilder();

    test('typeName + constructorName', () {
      expect(b.typeName, 'ListView');
      expect(b.constructorName, 'builder');
    });

    test('missing itemCount throws ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {'itemBuilder': _closureOf("(ctx, i) => Text('x')")},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing itemBuilder throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'itemCount': 3}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-closure itemBuilder throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'itemCount': 3, 'itemBuilder': 'not-a-closure'},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wrong-arity itemBuilder throws ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'itemCount': 3,
              'itemBuilder': _closureOf("(i) => Text('x')"),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('happy path: renders items via the closure', (tester) async {
      final widget = b.build(
        ResolvedArguments(
          named: {
            'itemCount': 3,
            'itemBuilder': _closureOf("(ctx, i) => Text('item')"),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(widget));
      expect(find.text('item'), findsWidgets);
    });
  });
}
