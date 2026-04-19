import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/navigation_rail_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget rail) => MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            rail,
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );

const _destA = NavigationRailDestination(
  icon: Icon(Icons.home),
  label: Text('Home'),
);
const _destB = NavigationRailDestination(
  icon: Icon(Icons.settings),
  label: Text('Settings'),
);

void main() {
  group('NavigationRailBuilder', () {
    const b = NavigationRailBuilder();

    test('typeName is "NavigationRail"', () {
      expect(b.typeName, 'NavigationRail');
    });

    testWidgets('renders with 2 destinations', (tester) async {
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
      expect(find.byType(NavigationRail), findsOneWidget);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.destinations.length, 2);
      expect(rail.selectedIndex, 0);
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
        if (name == 'railTapped') captured.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'destinations': <Object?>[_destA, _destB],
            'selectedIndex': 0,
            'onDestinationSelected': 'railTapped',
            'labelType': NavigationRailLabelType.all,
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
