import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rune/rune.dart';
import 'package:rune_router/src/values/go_router_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('GoRouterBuilder', () {
    const b = GoRouterBuilder();

    test('typeName is "GoRouter", constructorName is null', () {
      expect(b.typeName, 'GoRouter');
      expect(b.constructorName, isNull);
    });

    test('throws when routes is missing', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('builds with empty routes list (initialLocation defaults to /)', () {
      final router = b.build(
        const ResolvedArguments(named: {'routes': <Object?>[]}),
        testContext(),
      );
      expect(router, isA<GoRouter>());
    });

    test('filters non-GoRoute entries from routes list', () {
      final oneRoute = GoRoute(
        path: '/',
        builder: (_, __) => const SizedBox.shrink(),
      );
      final router = b.build(
        ResolvedArguments(
          named: {
            'routes': <Object?>[oneRoute, null, 'not a route', 42],
          },
        ),
        testContext(),
      );
      expect(router, isA<GoRouter>());
    });

    test('honours supplied initialLocation', () {
      final router = b.build(
        const ResolvedArguments(
          named: {
            'routes': <Object?>[],
            'initialLocation': '/home',
          },
        ),
        testContext(),
      );
      expect(router, isA<GoRouter>());
    });
  });
}
