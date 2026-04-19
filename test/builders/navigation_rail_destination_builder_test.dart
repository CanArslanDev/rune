import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/navigation_rail_destination_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('NavigationRailDestinationBuilder', () {
    const b = NavigationRailDestinationBuilder();

    test('typeName and constructorName are correct', () {
      expect(b.typeName, 'NavigationRailDestination');
      expect(b.constructorName, isNull);
    });

    test('builds with required icon + label', () {
      const icon = Icon(Icons.home);
      const label = Text('Home');
      final dest = b.build(
        const ResolvedArguments(
          named: {'icon': icon, 'label': label},
        ),
        testContext(),
      );
      expect(dest, isA<NavigationRailDestination>());
      expect(dest.icon, same(icon));
      expect(dest.label, same(label));
    });

    test('missing icon throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'label': Text('Home')}),
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
  });
}
