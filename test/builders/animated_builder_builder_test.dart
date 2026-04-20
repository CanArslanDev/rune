import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/animated_builder_builder.dart';
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
  group('AnimatedBuilderBuilder', () {
    const b = AnimatedBuilderBuilder();

    test('typeName is "AnimatedBuilder"', () {
      expect(b.typeName, 'AnimatedBuilder');
    });

    test('missing animation throws ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {'builder': _closureOf("(c, child) => Text('x')")},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-Listenable animation throws ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'animation': 42,
              'builder': _closureOf("(c, child) => Text('x')"),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing builder throws ArgumentException', () {
      const anim = AlwaysStoppedAnimation<double>(0);
      expect(
        () => b.build(
          const ResolvedArguments(named: <String, Object?>{'animation': anim}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wrong-arity builder throws ArgumentException', () {
      const anim = AlwaysStoppedAnimation<double>(0);
      expect(
        () => b.build(
          ResolvedArguments(
            named: <String, Object?>{
              'animation': anim,
              'builder': _closureOf("(c) => Text('x')"),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('invokes builder closure; renders result', (tester) async {
      const anim = AlwaysStoppedAnimation<double>(0.5);
      final w = b.build(
        ResolvedArguments(
          named: <String, Object?>{
            'animation': anim,
            'builder': _closureOf("(c, child) => Text('tick')"),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(w));
      expect(find.text('tick'), findsOneWidget);
    });

    testWidgets('static child is hoisted and passed to closure',
        (tester) async {
      const anim = AlwaysStoppedAnimation<double>(0);
      const hoisted = SizedBox(key: Key('hoisted'), width: 10, height: 10);
      final w = b.build(
        ResolvedArguments(
          named: <String, Object?>{
            'animation': anim,
            'child': hoisted,
            'builder': _closureOf("(c, child) => Text('x')"),
          },
        ),
        testContext(),
      ) as AnimatedBuilder;
      expect(w.child, same(hoisted));
    });
  });
}
