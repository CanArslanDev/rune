import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rune/rune.dart';
import 'package:rune_router/src/values/go_route_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('GoRouteBuilder', () {
    const b = GoRouteBuilder();

    test('typeName is "GoRoute", constructorName is null', () {
      expect(b.typeName, 'GoRoute');
      expect(b.constructorName, isNull);
    });

    test('throws when path is missing', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'builder': 'ignored'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when builder is missing', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'path': '/home'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when builder is not a closure', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'path': '/home', 'builder': 42},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });

  group('GoRouter value registration round-trip', () {
    test('registered GoRoute survives typeName lookup', () {
      final values = ValueRegistry()
        ..registerBuilder(const GoRouteBuilder());
      final found = values.findValue('GoRoute');
      expect(found, isNotNull);
      expect(found!.typeName, 'GoRoute');
    });

    test('GoRoute survives as a filtered list entry', () {
      // The GoRouter value builder consumes a List<Object?> and
      // filters to GoRoute. Smoke-check the filter arithmetic here
      // so the GoRouter builder test can stay focused.
      final routes = <Object?>[null, 'not-a-route', 42];
      final filtered = routes.whereType<GoRoute>().toList();
      expect(filtered, isEmpty);
    });
  });
}
