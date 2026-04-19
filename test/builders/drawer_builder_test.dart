import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/drawer_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('DrawerBuilder', () {
    const b = DrawerBuilder();

    test('typeName is "Drawer"', () {
      expect(b.typeName, 'Drawer');
    });

    test('child plumbs through', () {
      const child = Text('menu');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as Drawer;
      expect(w.child, same(child));
    });

    test('backgroundColor + elevation + width plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'backgroundColor': Color(0xFF112233),
            'elevation': 4,
            'width': 280,
          },
        ),
        testContext(),
      ) as Drawer;
      expect(w.backgroundColor, const Color(0xFF112233));
      expect(w.elevation, 4.0);
      expect(w.width, 280.0);
    });

    test('no-args renders without throwing', () {
      final w = b.build(ResolvedArguments.empty, testContext()) as Drawer;
      expect(w.child, isNull);
      expect(w.backgroundColor, isNull);
      expect(w.elevation, isNull);
      expect(w.width, isNull);
    });
  });
}
