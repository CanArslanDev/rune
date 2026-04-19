import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/ink_well_builder.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('InkWellBuilder', () {
    const b = InkWellBuilder();

    test('typeName is "InkWell"', () {
      expect(b.typeName, 'InkWell');
    });

    testWidgets('wraps child widget under a Material ancestor',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'child': Text('ink me')}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.text('ink me'), findsOneWidget);
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
            'onTap': 'inkTappedEvent',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(names, ['inkTappedEvent']);
      expect(argLists, [<Object?>[]]);
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
            'onLongPress': 'inkLongPressedEvent',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.longPress(find.byType(InkWell));
      await tester.pump();
      expect(names, ['inkLongPressedEvent']);
    });

    testWidgets('borderRadius plumbs through to the rendered InkWell',
        (tester) async {
      final built = b.build(
        ResolvedArguments(
          named: {
            'child': const Text('Rounded'),
            'borderRadius': BorderRadius.circular(8),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, BorderRadius.circular(8));
    });
  });
}
