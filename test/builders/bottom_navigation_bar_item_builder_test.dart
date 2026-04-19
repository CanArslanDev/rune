import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/bottom_navigation_bar_item_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BottomNavigationBarItemBuilder', () {
    const b = BottomNavigationBarItemBuilder();

    test('typeName and constructorName are correct', () {
      expect(b.typeName, 'BottomNavigationBarItem');
      expect(b.constructorName, isNull);
    });

    test('builds with required icon + label', () {
      const icon = Icon(Icons.home);
      final item = b.build(
        const ResolvedArguments(
          named: {'icon': icon, 'label': 'Home'},
        ),
        testContext(),
      );
      expect(item, isA<BottomNavigationBarItem>());
      expect(item.icon, same(icon));
      expect(item.label, 'Home');
    });

    test('missing icon throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'label': 'Home'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing label throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'icon': Icon(Icons.home)}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('activeIcon, backgroundColor, tooltip plumb through', () {
      const icon = Icon(Icons.home);
      const activeIcon = Icon(Icons.home_filled);
      final item = b.build(
        const ResolvedArguments(
          named: {
            'icon': icon,
            'label': 'Home',
            'activeIcon': activeIcon,
            'backgroundColor': Colors.blue,
            'tooltip': 'Go home',
          },
        ),
        testContext(),
      );
      expect(item.activeIcon, same(activeIcon));
      expect(item.backgroundColor, Colors.blue);
      expect(item.tooltip, 'Go home');
    });
  });
}
