import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rune/rune.dart';
import 'package:rune_router/rune_router.dart';

RuneConfig _config() =>
    RuneConfig.defaults().withBridges(const [RouterBridge()]);

void main() {
  group('RouterBridge integration through RuneView', () {
    testWidgets('declares an inline GoRouterApp with a single route',
        (tester) async {
      await tester.pumpWidget(
        RuneView(
          config: _config(),
          source: '''
            GoRouterApp(
              router: GoRouter(
                initialLocation: '/',
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (ctx, state) => Scaffold(
                      body: Center(child: Text('home')),
                    ),
                  ),
                ],
              ),
            )
          ''',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets(
      'host-side GoRouter.go navigates the source-declared routes',
      (tester) async {
        // Host builds the router; source mounts it through
        // GoRouterApp. Navigation happens via a reference the host
        // keeps (the idiomatic go_router pattern).
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const Scaffold(body: Text('home-page')),
            ),
            GoRoute(
              path: '/settings',
              builder: (_, __) =>
                  const Scaffold(body: Text('settings-page')),
            ),
          ],
        );

        await tester.pumpWidget(
          RuneView(
            config: _config(),
            data: {'router': router},
            source: '''
              GoRouterApp(router: router)
            ''',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('home-page'), findsOneWidget);
        expect(find.text('settings-page'), findsNothing);

        router.go('/settings');
        await tester.pumpAndSettle();
        expect(find.text('settings-page'), findsOneWidget);
      },
    );
  });
}
