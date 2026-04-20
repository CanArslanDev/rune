import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_tab_bar_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoTabBarBuilder', () {
    const b = CupertinoTabBarBuilder();

    const items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.settings),
        label: 'Settings',
      ),
    ];

    test('typeName is "CupertinoTabBar"', () {
      expect(b.typeName, 'CupertinoTabBar');
    });

    test('requires items', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('filters non-BottomNavigationBarItem entries from items', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'items': <Object?>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: 'Settings',
              ),
              42,
              null,
            ],
          },
        ),
        testContext(),
      ) as CupertinoTabBar;
      expect(w.items.length, 2);
    });

    test('defaults currentIndex to 0 and forwards it when supplied', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'items': items,
            'currentIndex': 1,
          },
        ),
        testContext(),
      ) as CupertinoTabBar;
      expect(w.currentIndex, 1);
    });

    test('onTap string dispatches with the tapped index', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'tabTapped') captured.add(args);
      });
      final w = b.build(
        const ResolvedArguments(
          named: {
            'items': items,
            'onTap': 'tabTapped',
          },
        ),
        testContext(events: events),
      ) as CupertinoTabBar;
      w.onTap!.call(1);
      expect(captured, [
        [1],
      ]);
    });

    test('styling params (colors, iconSize) forward', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'items': items,
            'backgroundColor': Color(0xFF112233),
            'activeColor': Color(0xFF223344),
            'inactiveColor': Color(0xFF334455),
            'iconSize': 24.0,
          },
        ),
        testContext(),
      ) as CupertinoTabBar;
      expect(w.backgroundColor, const Color(0xFF112233));
      expect(w.activeColor, const Color(0xFF223344));
      expect(w.inactiveColor, const Color(0xFF334455));
      expect(w.iconSize, 24.0);
    });
  });
}
