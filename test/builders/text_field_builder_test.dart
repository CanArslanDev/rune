import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/text_field_builder.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('TextFieldBuilder', () {
    const b = TextFieldBuilder();

    test('typeName is "TextField"', () {
      expect(b.typeName, 'TextField');
    });

    testWidgets('initial value populates the field', (tester) async {
      final ctx = testContext();
      final built = b.build(
        const ResolvedArguments(named: {'value': 'hello'}),
        ctx,
      );
      await tester.pumpWidget(_harness(built));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('typing dispatches onChanged event with new text',
        (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'usernameChanged') captured.add(args);
      });
      final ctx = testContext(events: events);
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': '',
            'onChanged': 'usernameChanged',
          },
        ),
        ctx,
      );
      await tester.pumpWidget(_harness(built));
      await tester.enterText(find.byType(TextField), 'world');
      await tester.pump();
      expect(captured.length, greaterThanOrEqualTo(1));
      expect(captured.last, ['world']);
    });

    testWidgets('external value update syncs controller without dispatching',
        (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'changed') captured.add(args);
      });
      final ctx = testContext(events: events);
      final first = b.build(
        const ResolvedArguments(
          named: {'value': 'a', 'onChanged': 'changed'},
        ),
        ctx,
      );
      await tester.pumpWidget(_harness(first));
      expect(find.text('a'), findsOneWidget);

      final second = b.build(
        const ResolvedArguments(
          named: {'value': 'b', 'onChanged': 'changed'},
        ),
        ctx,
      );
      await tester.pumpWidget(_harness(second));
      await tester.pump();
      expect(find.text('b'), findsOneWidget);
      expect(captured, isEmpty);
    });

    testWidgets(
      'missing onChanged leaves field editable locally, dispatches nothing',
      (tester) async {
        final events = RuneEventDispatcher();
        var observed = false;
        events.setCatchAllHandler((_, __) => observed = true);
        final ctx = testContext(events: events);
        final built = b.build(
          const ResolvedArguments(named: {'value': ''}),
          ctx,
        );
        await tester.pumpWidget(_harness(built));
        await tester.enterText(find.byType(TextField), 'local');
        await tester.pump();
        expect(find.text('local'), findsOneWidget);
        expect(observed, isFalse);
      },
    );

    testWidgets('obscureText plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {'value': 'pw', 'obscureText': true},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.obscureText, isTrue);
    });

    testWidgets('labelText plumbs through decoration', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'labelText': 'Username'}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration?.labelText, 'Username');
    });

    testWidgets('hintText plumbs through decoration', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'hintText': 'Type here'}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration?.hintText, 'Type here');
    });

    testWidgets('enabled: false disables the field', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'enabled': false}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.enabled, isFalse);
    });

    testWidgets('enabled defaults to true', (tester) async {
      final built = b.build(ResolvedArguments.empty, testContext());
      await tester.pumpWidget(_harness(built));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.enabled, isTrue);
    });

    testWidgets(
      'maxLines: null explicit is preserved (not coerced to 1)',
      (tester) async {
        final built = b.build(
          const ResolvedArguments(named: {'maxLines': null}),
          testContext(),
        );
        await tester.pumpWidget(_harness(built));
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.maxLines, isNull);
      },
    );

    testWidgets('maxLines defaults to 1 when absent', (tester) async {
      final built = b.build(ResolvedArguments.empty, testContext());
      await tester.pumpWidget(_harness(built));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.maxLines, 1);
    });

    testWidgets('maxLines: 3 plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'maxLines': 3}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.maxLines, 3);
    });
  });
}
