import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

void main() {
  group('v1.7.0 smoke: gesture primitives', () {
    testWidgets('Draggable + DragTarget drop dispatches named event',
        (tester) async {
      final captured = <Object?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RuneView(
              source: '''
                Column(
                  children: [
                    Draggable(
                      data: 'payload',
                      feedback: SizedBox(
                        width: 40,
                        height: 40,
                        child: Text('flying'),
                      ),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Text('D'),
                      ),
                    ),
                    DragTarget(
                      builder: (ctx, cand, rej) => SizedBox(
                        width: 160,
                        height: 160,
                        child: Text('T'),
                      ),
                      onAcceptWithDetails: 'drop',
                    ),
                  ],
                )
              ''',
              config: RuneConfig.defaults(),
              onEvent: (name, [args]) {
                if (name == 'drop' && args != null) {
                  captured.add(args[0]);
                }
              },
            ),
          ),
        ),
      );
      expect(find.text('D'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);

      final from = tester.getCenter(find.text('D'));
      final to = tester.getCenter(find.text('T'));
      final gesture = await tester.startGesture(from);
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveTo(to);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(captured, hasLength(1));
      final details = captured.single! as DragTargetDetails<Object>;
      expect(details.data, 'payload');
      expect(tester.takeException(), isNull);
    });

    testWidgets('Dismissible swipe removes a keyed item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RuneView(
              source: '''
                StatefulBuilder(
                  initial: {'items': ['a', 'b', 'c']},
                  builder: (state) => ListView(
                    children: state.items.map((id) => Dismissible(
                      key: ValueKey(id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (dir) => state.set(
                        'items',
                        state.items.where((x) => x != id),
                      ),
                      background: ColoredBox(color: Colors.red),
                      child: ListTile(title: Text(id)),
                    )),
                  ),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        ),
      );
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);

      await tester.drag(find.text('b'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('b'), findsNothing);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ReorderableListView renders keyed entries end-to-end',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RuneView(
              source: '''
                ReorderableListView(
                  onReorder: (oldIndex, newIndex) => 0,
                  children: [
                    ListTile(key: ValueKey('a'), title: Text('Alpha')),
                    ListTile(key: ValueKey('b'), title: Text('Beta')),
                    ListTile(key: ValueKey('c'), title: Text('Gamma')),
                  ],
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        ),
      );
      expect(find.byType(ReorderableListView), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('InteractiveViewer renders a pannable child and does not'
        ' throw when panned', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: RuneView(
                source: '''
                  InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: ColoredBox(color: Colors.blue),
                    ),
                  )
                ''',
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(InteractiveViewer), findsOneWidget);
      await tester.drag(
        find.byType(InteractiveViewer),
        const Offset(20, 20),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
