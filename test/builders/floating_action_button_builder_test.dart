import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/floating_action_button_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FloatingActionButtonBuilder', () {
    const b = FloatingActionButtonBuilder();

    test('typeName is "FloatingActionButton"', () {
      expect(b.typeName, 'FloatingActionButton');
    });

    testWidgets('renders child Icon', (tester) async {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'child': Icon(Icons.add),
            'onPressed': 'noop',
          },
        ),
        testContext(),
      ) as FloatingActionButton;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: w)),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    test('onPressed dispatches named event', () {
      final events = RuneEventDispatcher();
      var count = 0;
      events.register('addTapped', () => count++);
      final ctx = testContext(events: events);
      final w = b.build(
        const ResolvedArguments(named: {'onPressed': 'addTapped'}),
        ctx,
      ) as FloatingActionButton;

      expect(w.onPressed, isNotNull);
      w.onPressed!.call();
      expect(count, 1);
    });

    test('missing onPressed leaves FAB disabled', () {
      final w = b.build(
        ResolvedArguments.empty,
        testContext(),
      ) as FloatingActionButton;
      expect(w.onPressed, isNull);
    });

    test('tooltip/backgroundColor/foregroundColor plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'onPressed': 'noop',
            'tooltip': 'Add item',
            'backgroundColor': Color(0xFF0088FF),
            'foregroundColor': Color(0xFFFFFFFF),
          },
        ),
        testContext(),
      ) as FloatingActionButton;
      expect(w.tooltip, 'Add item');
      expect(w.backgroundColor, const Color(0xFF0088FF));
      expect(w.foregroundColor, const Color(0xFFFFFFFF));
    });

    test('mini defaults to false and plumbs through when true', () {
      final defaultW = b.build(
        const ResolvedArguments(named: {'onPressed': 'noop'}),
        testContext(),
      ) as FloatingActionButton;
      expect(defaultW.mini, isFalse);

      final miniW = b.build(
        const ResolvedArguments(
          named: {'onPressed': 'noop', 'mini': true},
        ),
        testContext(),
      ) as FloatingActionButton;
      expect(miniW.mini, isTrue);
    });
  });
}
