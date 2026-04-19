import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/navigation_bar_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget bar) => MaterialApp(
      home: Scaffold(
        body: const SizedBox.shrink(),
        bottomNavigationBar: bar,
      ),
    );

const _destA = NavigationDestination(icon: Icon(Icons.home), label: 'Home');
const _destB = NavigationDestination(
  icon: Icon(Icons.settings),
  label: 'Settings',
);

void main() {
  group('NavigationBarBuilder', () {
    const b = NavigationBarBuilder();

    test('typeName is "NavigationBar"', () {
      expect(b.typeName, 'NavigationBar');
    });

    testWidgets('renders with 2 destinations + selectedIndex: 0',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'destinations': <Object?>[_destA, _destB],
            'selectedIndex': 0,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(NavigationBar), findsOneWidget);
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.destinations.length, 2);
      expect(bar.selectedIndex, 0);
    });

    test('missing destinations throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'selectedIndex': 0}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('single-destination throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'destinations': <Object?>[_destA],
              'selectedIndex': 0,
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('onDestinationSelected dispatches (eventName, [newIndex])',
        (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'navTapped') captured.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'destinations': <Object?>[_destA, _destB],
            'selectedIndex': 0,
            'onDestinationSelected': 'navTapped',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(captured, [
        [1],
      ]);
    });
  });
}
