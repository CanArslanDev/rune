import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/elevated_button_builder.dart';
import 'package:rune/src/builders/widgets/stateful_builder_builder.dart';
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

/// Parses [source] as a function-expression literal and wraps it as a
/// [RuneClosure] with a fully wired resolver pipeline including Text
/// and ElevatedButton in the widget registry.
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
  final widgets = WidgetRegistry()
    ..registerBuilder(const TextBuilder())
    ..registerBuilder(const ElevatedButtonBuilder());
  final capturedCtx = ctx ?? testContext(widgets: widgets);
  return RuneClosure.expression(
    parameterNames: paramNames,
    body: body,
    capturedContext: capturedCtx,
    resolver: expr,
  );
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('StatefulBuilderBuilder', () {
    const b = StatefulBuilderBuilder();

    test('typeName is "StatefulBuilder"', () {
      expect(b.typeName, 'StatefulBuilder');
    });

    testWidgets('missing initial throws ArgumentException', (tester) async {
      final closure = _closureOf('(state) => state');
      expect(
        () => b.build(
          ResolvedArguments(named: {'builder': closure}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('missing builder throws ArgumentException', (tester) async {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'initial': <Object?, Object?>{'x': 1},
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('non-closure builder throws ArgumentException',
        (tester) async {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'initial': <Object?, Object?>{'x': 1},
              'builder': 'not-a-closure',
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets(
      'builder with wrong arity (0 params) throws ArgumentException',
      (tester) async {
        final closure = _closureOf('() => 1');
        expect(
          () => b.build(
            ResolvedArguments(
              named: {
                'initial': const <Object?, Object?>{'x': 1},
                'builder': closure,
              },
            ),
            testContext(),
          ),
          throwsA(isA<ArgumentException>()),
        );
      },
    );

    testWidgets(
      'builder with wrong arity (2 params) throws ArgumentException',
      (tester) async {
        final closure = _closureOf('(a, b) => a');
        expect(
          () => b.build(
            ResolvedArguments(
              named: {
                'initial': const <Object?, Object?>{'x': 1},
                'builder': closure,
              },
            ),
            testContext(),
          ),
          throwsA(isA<ArgumentException>()),
        );
      },
    );

    testWidgets(
      'happy path: renders the closure-returned Text with state.x = 5',
      (tester) async {
        final closure = _closureOf(r"(state) => Text('x=${state.x}')");
        await tester.pumpWidget(
          _wrap(
            b.build(
              ResolvedArguments(
                named: {
                  'initial': const <Object?, Object?>{'x': 5},
                  'builder': closure,
                },
              ),
              testContext(),
            ),
          ),
        );
        expect(find.text('x=5'), findsOneWidget);
      },
    );

    testWidgets(
      'state mutation rebuilds: tapping ElevatedButton updates Text',
      (tester) async {
        // Closure source: a Column with a Text reflecting state.counter
        // and an ElevatedButton whose onPressed closure mutates state
        // via state.set. Tapping the button triggers the onMutation
        // callback wired in _StatefulHostState → setState → rebuild.
        //
        // We build the Column + ElevatedButton + Text chain manually
        // rather than through the defaults registry so this test only
        // depends on Phase C wiring.
        const src = r'''
(state) => ElevatedButton(
  onPressed: () => state.set('counter', state.counter + 1),
  child: Text('count=${state.counter}'),
)''';
        final closure = _closureOf(src);
        await tester.pumpWidget(
          _wrap(
            b.build(
              ResolvedArguments(
                named: {
                  'initial': const <Object?, Object?>{'counter': 0},
                  'builder': closure,
                },
              ),
              testContext(),
            ),
          ),
        );
        expect(find.text('count=0'), findsOneWidget);

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text('count=1'), findsOneWidget);
      },
    );

    testWidgets(
      'mutation mid-build is deferred via post-frame scheduling',
      (tester) async {
        // The closure body calls state.set on first render when
        // `init_called` is absent. A naive setState-in-build would
        // assert; _StatefulHostState defers via addPostFrameCallback.
        //
        // Conditional-expression guard stops infinite rebuilds: once
        // the flag is set, subsequent builds are no-ops.
        //
        // Returns the Text with the flag inlined via interpolation;
        // `state.set` returns null (void) so we route through a Column
        // that reads the state only AFTER the set-or-skip has run.
        const src = r'''
(state) => state.has('init_called')
    ? Text('init=true')
    : Text('init=${state.set('init_called', true)}')''';
        final closure = _closureOf(src);
        await tester.pumpWidget(
          _wrap(
            b.build(
              ResolvedArguments(
                named: {
                  'initial': const <Object?, Object?>{'x': 1},
                  'builder': closure,
                },
              ),
              testContext(),
            ),
          ),
        );
        // Flush post-frame callback + its setState.
        await tester.pumpAndSettle();
        expect(find.text('init=true'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
