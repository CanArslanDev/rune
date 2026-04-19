import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/tab_bar_builder.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget bar, {int length = 2}) => MaterialApp(
      home: DefaultTabController(
        length: length,
        child: Scaffold(
          appBar: AppBar(
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: bar,
            ),
          ),
        ),
      ),
    );

void main() {
  group('TabBarBuilder', () {
    const b = TabBarBuilder();

    test('typeName is "TabBar"', () {
      expect(b.typeName, 'TabBar');
    });

    testWidgets('renders with 2 tabs', (tester) async {
      const t1 = Tab(text: 'Home');
      const t2 = Tab(text: 'Settings');
      final built = b.build(
        const ResolvedArguments(
          named: {
            'tabs': <Object?>[t1, t2],
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(2));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('theming and isScrollable plumb through', (tester) async {
      const t1 = Tab(text: 'One');
      const t2 = Tab(text: 'Two');
      final built = b.build(
        const ResolvedArguments(
          named: {
            'tabs': <Object?>[t1, t2],
            'indicatorColor': Colors.red,
            'labelColor': Colors.black,
            'unselectedLabelColor': Colors.grey,
            'isScrollable': true,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.indicatorColor, Colors.red);
      expect(tabBar.labelColor, Colors.black);
      expect(tabBar.unselectedLabelColor, Colors.grey);
      expect(tabBar.isScrollable, isTrue);
    });

    testWidgets('tapping a tab dispatches (eventName, [newIndex])',
        (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'tabTapped') captured.add(args);
      });
      const t1 = Tab(text: 'Home');
      const t2 = Tab(text: 'Settings');
      final built = b.build(
        const ResolvedArguments(
          named: {
            'tabs': <Object?>[t1, t2],
            'onTap': 'tabTapped',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(captured, [
        [1],
      ]);
    });
  });
}
