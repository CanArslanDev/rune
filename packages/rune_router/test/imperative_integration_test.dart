// v0.2.0 integration: when RouterBridge is constructed with a
// GoRouter, it registers `Router.go` / `Router.push` / `Router.pop` /
// `Router.pushReplacement` / `Router.goNamed` / `Router.pushNamed` as
// prefixed imperatives on config.imperatives, so Rune source can
// drive navigation without bouncing through onEvent + host Dart.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rune/rune.dart';
import 'package:rune_router/rune_router.dart';

void main() {
  group('RouterBridge v0.2.0 imperative registration', () {
    test('no router argument: Router.* imperatives are NOT registered', () {
      final config = RuneConfig.defaults()
          .withBridges(const [RouterBridge()]);
      expect(config.imperatives.findPrefixed('Router', 'go'), isNull);
      expect(config.imperatives.findPrefixed('Router', 'push'), isNull);
    });

    test(
      'router argument: Router.go / push / pop / pushReplacement / '
      'goNamed / pushNamed are all registered as prefixed imperatives',
      () {
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const SizedBox.shrink(),
            ),
          ],
        );
        addTearDown(router.dispose);

        final config = RuneConfig.defaults()
            .withBridges([RouterBridge(router: router)]);

        for (final name in const [
          'go',
          'push',
          'pop',
          'pushReplacement',
          'goNamed',
          'pushNamed',
        ]) {
          expect(
            config.imperatives.findPrefixed('Router', name),
            isNotNull,
            reason: 'Router.$name should be registered when router is passed',
          );
        }
      },
    );

    testWidgets(
      'Router.go from a source-level onPressed switches the active route',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => Scaffold(
                body: Builder(
                  builder: (ctx) => RuneView(
                    config: RuneConfig.defaults()
                        .withBridges([RouterBridge(router: GoRouter.of(ctx))]),
                    source: '''
                      ElevatedButton(
                        onPressed: () => Router.go('/settings'),
                        child: Text('go-settings'),
                      )
                    ''',
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/settings',
              builder: (_, __) => const Scaffold(body: Text('on-settings')),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('go-settings'), findsOneWidget);
        await tester.tap(find.text('go-settings'));
        await tester.pumpAndSettle();
        expect(find.text('on-settings'), findsOneWidget);
      },
    );

    testWidgets(
      'Router.push from source pushes a route that Router.pop can clear',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => Scaffold(
                body: Builder(
                  builder: (ctx) => RuneView(
                    config: RuneConfig.defaults()
                        .withBridges([RouterBridge(router: GoRouter.of(ctx))]),
                    source: '''
                      ElevatedButton(
                        onPressed: () => Router.push('/details'),
                        child: Text('push-details'),
                      )
                    ''',
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/details',
              builder: (_, __) => Scaffold(
                body: Builder(
                  builder: (ctx) => RuneView(
                    config: RuneConfig.defaults()
                        .withBridges([RouterBridge(router: GoRouter.of(ctx))]),
                    source: '''
                      ElevatedButton(
                        onPressed: () => Router.pop(),
                        child: Text('pop-back'),
                      )
                    ''',
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        await tester.tap(find.text('push-details'));
        await tester.pumpAndSettle();
        expect(find.text('pop-back'), findsOneWidget);

        await tester.tap(find.text('pop-back'));
        await tester.pumpAndSettle();
        expect(find.text('push-details'), findsOneWidget);
      },
    );
  });
}
