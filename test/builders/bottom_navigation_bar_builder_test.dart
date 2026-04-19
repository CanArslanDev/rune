import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/bottom_navigation_bar_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget bar) => MaterialApp(
      home: Scaffold(
        body: const SizedBox.shrink(),
        bottomNavigationBar: bar,
      ),
    );

const _itemA = BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home');
const _itemB = BottomNavigationBarItem(
  icon: Icon(Icons.settings),
  label: 'Settings',
);

void main() {
  group('BottomNavigationBarBuilder', () {
    const b = BottomNavigationBarBuilder();

    test('typeName is "BottomNavigationBar"', () {
      expect(b.typeName, 'BottomNavigationBar');
    });

    testWidgets('renders with 2 items + currentIndex: 0', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'items': <Object?>[_itemA, _itemB],
            'currentIndex': 0,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.items.length, 2);
      expect(bar.currentIndex, 0);
    });

    test('missing items throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'currentIndex': 0}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('single-item items throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'items': <Object?>[_itemA],
              'currentIndex': 0,
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing currentIndex throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'items': <Object?>[_itemA, _itemB],
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('tapping a tab dispatches (eventName, [newIndex])',
        (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'navTapped') captured.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'items': <Object?>[_itemA, _itemB],
            'currentIndex': 0,
            'onTap': 'navTapped',
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

    testWidgets('theming args plumb through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'items': <Object?>[_itemA, _itemB],
            'currentIndex': 0,
            'type': BottomNavigationBarType.fixed,
            'selectedItemColor': Colors.red,
            'unselectedItemColor': Colors.grey,
            'backgroundColor': Colors.white,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.type, BottomNavigationBarType.fixed);
      expect(bar.selectedItemColor, Colors.red);
      expect(bar.unselectedItemColor, Colors.grey);
      expect(bar.backgroundColor, Colors.white);
    });
  });
}
