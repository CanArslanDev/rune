import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/gesture_detector_builder.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('GestureDetectorBuilder', () {
    const b = GestureDetectorBuilder();

    test('typeName is "GestureDetector"', () {
      expect(b.typeName, 'GestureDetector');
    });

    testWidgets('wraps child widget without any callbacks', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'child': Text('tap me')}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.text('tap me'), findsOneWidget);
    });

    testWidgets('onTap event name dispatches with empty args when tapped',
        (tester) async {
      final events = RuneEventDispatcher();
      final names = <String>[];
      final argLists = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        names.add(name);
        argLists.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('Tap'),
            'onTap': 'tappedEvent',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(names, ['tappedEvent']);
      expect(argLists, [<Object?>[]]);
    });

    testWidgets('onDoubleTap event name dispatches on double-tap',
        (tester) async {
      final events = RuneEventDispatcher();
      final names = <String>[];
      events.setCatchAllHandler((name, args) => names.add(name));
      final built = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('Double'),
            'onDoubleTap': 'doubleTappedEvent',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      final center = tester.getCenter(find.byType(GestureDetector));
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 50));
      expect(names, ['doubleTappedEvent']);
    });

    testWidgets('onLongPress event name dispatches on long press',
        (tester) async {
      final events = RuneEventDispatcher();
      final names = <String>[];
      events.setCatchAllHandler((name, args) => names.add(name));
      final built = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('Long'),
            'onLongPress': 'longPressedEvent',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.longPress(find.byType(GestureDetector));
      await tester.pump();
      expect(names, ['longPressedEvent']);
    });

    testWidgets('missing all events leaves callbacks null', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'child': Text('No cb')}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final gd = tester.widget<GestureDetector>(find.byType(GestureDetector));
      expect(gd.onTap, isNull);
      expect(gd.onDoubleTap, isNull);
      expect(gd.onLongPress, isNull);
    });
  });
}
