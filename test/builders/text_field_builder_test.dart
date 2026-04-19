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

    testWidgets(
      'external controller: supplied controller is used by the TextField',
      (tester) async {
        final external = TextEditingController(text: 'external-seed');
        addTearDown(external.dispose);
        final built = b.build(
          ResolvedArguments(named: {'controller': external}),
          testContext(),
        );
        await tester.pumpWidget(_harness(built));
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(identical(tf.controller, external), isTrue);
        expect(find.text('external-seed'), findsOneWidget);
      },
    );

    testWidgets(
      'external controller: value arg does not overwrite its text',
      (tester) async {
        final external = TextEditingController(text: 'from-controller');
        addTearDown(external.dispose);
        final built = b.build(
          ResolvedArguments(
            named: {
              'controller': external,
              'value': 'from-value',
            },
          ),
          testContext(),
        );
        await tester.pumpWidget(_harness(built));
        // External controller wins: its text is preserved, not clobbered.
        expect(external.text, 'from-controller');
        expect(find.text('from-controller'), findsOneWidget);
      },
    );

    testWidgets(
      'external controller: switching from internal to external on rebuild',
      (tester) async {
        final ctx = testContext();
        // First mount with NO external controller: internal wins.
        final first = b.build(
          const ResolvedArguments(named: {'value': 'starter'}),
          ctx,
        );
        await tester.pumpWidget(_harness(first));
        expect(find.text('starter'), findsOneWidget);
        final tf1 = tester.widget<TextField>(find.byType(TextField));
        final internal = tf1.controller;
        expect(internal, isNotNull);

        // Rebuild with an external controller supplied.
        final external = TextEditingController(text: 'swapped');
        addTearDown(external.dispose);
        final second = b.build(
          ResolvedArguments(named: {'controller': external}),
          ctx,
        );
        await tester.pumpWidget(_harness(second));
        final tf2 = tester.widget<TextField>(find.byType(TextField));
        expect(identical(tf2.controller, external), isTrue);
        expect(find.text('swapped'), findsOneWidget);
      },
    );

    testWidgets(
      'external controller: not disposed when the widget unmounts',
      (tester) async {
        final external = TextEditingController(text: 'keepalive');
        addTearDown(external.dispose);
        final built = b.build(
          ResolvedArguments(named: {'controller': external}),
          testContext(),
        );
        await tester.pumpWidget(_harness(built));
        expect(
          identical(
            tester.widget<TextField>(find.byType(TextField)).controller,
            external,
          ),
          isTrue,
        );

        // Unmount the Rune-built TextField.
        await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
        await tester.pumpAndSettle();

        // External controller must still be alive: calling any method that
        // a disposed controller throws on should succeed.
        expect(() => external.text = 'still-alive', returnsNormally);
        expect(external.text, 'still-alive');
      },
    );
  });
}
