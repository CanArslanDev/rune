import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/rune_cupertino.dart';
import 'package:rune_cupertino/src/widgets/cupertino_tab_scaffold_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoTabScaffoldBuilder', () {
    const b = CupertinoTabScaffoldBuilder();
    final tabBar = CupertinoTabBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'H'),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.settings),
          label: 'S',
        ),
      ],
    );

    test('typeName is "CupertinoTabScaffold"', () {
      expect(b.typeName, 'CupertinoTabScaffold');
    });

    test('requires tabBar', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'tabBuilder': 'not-a-closure'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('requires tabBuilder', () {
      expect(
        () => b.build(
          ResolvedArguments(named: {'tabBar': tabBar}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('rejects non-closure tabBuilder with ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {'tabBar': tabBar, 'tabBuilder': 'not-a-closure'},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets(
      'builds CupertinoTabScaffold end-to-end through RuneView',
      (tester) async {
        final config = RuneConfig.defaults()
            .withBridges(const [CupertinoBridge()]);
        await tester.pumpWidget(
          CupertinoApp(
            home: RuneView(
              config: config,
              source: '''
                CupertinoTabScaffold(
                  tabBar: CupertinoTabBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.settings),
                        label: 'Settings',
                      ),
                    ],
                  ),
                  tabBuilder: (ctx, index) => Center(child: Text('Tab-body')),
                )
              ''',
            ),
          ),
        );
        expect(find.byType(CupertinoTabScaffold), findsOneWidget);
        expect(find.text('Tab-body'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      },
    );

    testWidgets(
      'backgroundColor flows through RuneView source',
      (tester) async {
        final config = RuneConfig.defaults()
            .withBridges(const [CupertinoBridge()]);
        await tester.pumpWidget(
          CupertinoApp(
            home: RuneView(
              config: config,
              source: '''
                CupertinoTabScaffold(
                  backgroundColor: Color(0xFF123456),
                  tabBar: CupertinoTabBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.settings),
                        label: 'Settings',
                      ),
                    ],
                  ),
                  tabBuilder: (ctx, index) => Text('t'),
                )
              ''',
            ),
          ),
        );
        final scaffold = tester.widget<CupertinoTabScaffold>(
          find.byType(CupertinoTabScaffold),
        );
        expect(scaffold.backgroundColor, const Color(0xFF123456));
      },
    );
  });
}
