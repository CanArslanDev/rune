import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rune/rune.dart';
import 'package:rune_router/src/widgets/go_router_app_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('GoRouterAppBuilder', () {
    const b = GoRouterAppBuilder();

    test('typeName is "GoRouterApp"', () {
      expect(b.typeName, 'GoRouterApp');
    });

    test('throws when router is missing', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('installs the supplied GoRouter through MaterialApp.router',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (ctx, state) => const Scaffold(
              body: Text('home-page'),
            ),
          ),
        ],
      );
      final widget = b.build(
        ResolvedArguments(named: {'router': router, 'title': 'test'}),
        testContext(),
      );
      await tester.pumpWidget(widget);
      expect(find.text('home-page'), findsOneWidget);
    });
  });
}
