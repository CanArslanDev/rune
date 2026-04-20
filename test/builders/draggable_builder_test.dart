import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/draggable_builder.dart';
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
  group('DraggableBuilder', () {
    const b = DraggableBuilder();

    test('typeName is "Draggable"', () {
      expect(b.typeName, 'Draggable');
    });

    testWidgets('renders child and feedback widgets', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'data': 'payload',
            'child': Text('drag-me'),
            'feedback': Text('flying'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      expect(find.byType(Draggable<Object>), findsOneWidget);
      expect(find.text('drag-me'), findsOneWidget);
    });

    test('missing child raises ArgumentException citing Draggable', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'feedback': Text('x')},
          ),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>()
              .having((e) => e.source, 'source', 'Draggable'),
        ),
      );
    });

    test('missing feedback raises ArgumentException citing Draggable', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'child': Text('x')},
          ),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>()
              .having((e) => e.source, 'source', 'Draggable'),
        ),
      );
    });

    testWidgets('onDragStarted event name plumbs through to dispatcher',
        (tester) async {
      final events = RuneEventDispatcher();
      final names = <String>[];
      events.setCatchAllHandler((n, _) => names.add(n));
      final built = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('c'),
            'feedback': Text('f'),
            'onDragStarted': 'dragStartedEvent',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_wrap(built));
      final draggable = tester.widget<Draggable<Object>>(
        find.byType(Draggable<Object>),
      );
      draggable.onDragStarted!.call();
      expect(names, ['dragStartedEvent']);
    });

    testWidgets('onDragEnd closure fires with DraggableDetails',
        (tester) async {
      final built = b.build(
        ResolvedArguments(
          named: {
            'child': const Text('c'),
            'feedback': const Text('f'),
            'onDragEnd': _closureOf('(d) => 1'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      final draggable = tester.widget<Draggable<Object>>(
        find.byType(Draggable<Object>),
      );
      expect(draggable.onDragEnd, isNotNull);
    });
  });
}
