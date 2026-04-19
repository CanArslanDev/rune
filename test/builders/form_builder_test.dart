import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/form_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('FormBuilder', () {
    const b = FormBuilder();

    test('typeName is "Form"', () {
      expect(b.typeName, 'Form');
    });

    test('missing child raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('wraps the child in a Form', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'child': Text('inner')}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(Form), findsOneWidget);
      expect(find.text('inner'), findsOneWidget);
    });

    testWidgets('autovalidateMode plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('x'),
            'autovalidateMode': AutovalidateMode.always,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final form = tester.widget<Form>(find.byType(Form));
      expect(form.autovalidateMode, AutovalidateMode.always);
    });

    testWidgets('onChanged String dispatches a named event', (tester) async {
      final events = RuneEventDispatcher();
      final captured = <String>[];
      events.setCatchAllHandler((name, _) => captured.add(name));
      final ctx = testContext(events: events);
      final built = b.build(
        ResolvedArguments(
          named: {
            'child': TextFormField(),
            'onChanged': 'formTouched',
          },
        ),
        ctx,
      );
      await tester.pumpWidget(_harness(built));
      await tester.enterText(find.byType(TextFormField), 'x');
      await tester.pump();
      expect(captured, contains('formTouched'));
    });
  });
}
