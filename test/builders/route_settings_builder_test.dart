import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/route_settings_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('RouteSettingsBuilder', () {
    const b = RouteSettingsBuilder();

    test('typeName is "RouteSettings" and constructorName is null', () {
      expect(b.typeName, 'RouteSettings');
      expect(b.constructorName, isNull);
    });

    test('empty args produces a RouteSettings with null name and arguments',
        () {
      final s = b.build(ResolvedArguments.empty, testContext());
      expect(s, isA<RouteSettings>());
      expect(s.name, isNull);
      expect(s.arguments, isNull);
    });

    test('name plumbs through', () {
      final s = b.build(
        const ResolvedArguments(named: {'name': '/detail'}),
        testContext(),
      );
      expect(s.name, '/detail');
      expect(s.arguments, isNull);
    });

    test('arguments plumb through (Map of any shape)', () {
      final s = b.build(
        const ResolvedArguments(
          named: {
            'name': '/detail',
            'arguments': {'id': 42, 'preview': true},
          },
        ),
        testContext(),
      );
      expect(s.name, '/detail');
      expect(s.arguments, {'id': 42, 'preview': true});
    });

    test('arguments may be an arbitrary primitive', () {
      final s = b.build(
        const ResolvedArguments(named: {'arguments': 7}),
        testContext(),
      );
      expect(s.arguments, 7);
    });
  });
}
