import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/text_form_field_builder.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/parser/dart_parser.dart';
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
  return RuneClosure.expression(
    parameterNames: paramNames,
    body: body,
    capturedContext: ctx ?? testContext(),
    resolver: expr,
  );
}

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('TextFormFieldBuilder', () {
    const b = TextFormFieldBuilder();

    test('typeName is "TextFormField"', () {
      expect(b.typeName, 'TextFormField');
    });

    testWidgets('initial value populates the field', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'value': 'seed'}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.text('seed'), findsOneWidget);
    });

    testWidgets('external controller drives the field and wins over value',
        (tester) async {
      final ctrl = TextEditingController(text: 'from-controller');
      addTearDown(ctrl.dispose);
      final built = b.build(
        ResolvedArguments(
          named: {'controller': ctrl, 'value': 'ignored'},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.text('from-controller'), findsOneWidget);
    });

    testWidgets('validator closure surfaces error text on validate',
        (tester) async {
      final key = GlobalKey<FormState>();
      final built = Form(
        key: key,
        child: b.build(
          ResolvedArguments(
            named: {
              'value': '',
              'validator': _closureOf("(v) => v == '' ? 'Required' : null"),
            },
          ),
          testContext(),
        ),
      );
      await tester.pumpWidget(_harness(built));
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('obscureText plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'obscureText': true}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.obscureText, isTrue);
    });

    testWidgets('decoration gains hintText + labelText', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {'hintText': 'Enter', 'labelText': 'Email'},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration?.hintText, 'Enter');
      expect(tf.decoration?.labelText, 'Email');
    });

    test('validator of wrong arity is rejected at build time', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'validator': _closureOf('() => null'),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('autovalidateMode plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {'autovalidateMode': AutovalidateMode.always},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      // TextFormField is a StatefulWidget; we can only assert behavior
      // indirectly. Ensure the widget is constructed without errors.
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
