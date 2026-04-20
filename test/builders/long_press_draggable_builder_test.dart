import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/long_press_draggable_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('LongPressDraggableBuilder', () {
    const b = LongPressDraggableBuilder();

    test('typeName is "LongPressDraggable"', () {
      expect(b.typeName, 'LongPressDraggable');
    });

    testWidgets('renders child and feedback widgets', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'data': 42,
            'child': Text('lp-drag'),
            'feedback': Text('lp-flying'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      expect(find.byType(LongPressDraggable<Object>), findsOneWidget);
      expect(find.text('lp-drag'), findsOneWidget);
    });

    test('missing child raises ArgumentException citing LongPressDraggable',
        () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'feedback': Text('x')},
          ),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>()
              .having((e) => e.source, 'source', 'LongPressDraggable'),
        ),
      );
    });

    test(
        'missing feedback raises ArgumentException citing LongPressDraggable',
        () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'child': Text('x')},
          ),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>()
              .having((e) => e.source, 'source', 'LongPressDraggable'),
        ),
      );
    });

    testWidgets('onDragStarted event name plumbs through to dispatcher',
        (tester) async {
      final events = RuneEventDispatcher();
      final names = <String>[];
      events.setCatchAllHandler((n, _) => names.add(n));
      final built = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('c'),
            'feedback': Text('f'),
            'onDragStarted': 'lpDragStarted',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_wrap(built));
      final widget = tester.widget<LongPressDraggable<Object>>(
        find.byType(LongPressDraggable<Object>),
      );
      widget.onDragStarted!.call();
      expect(names, ['lpDragStarted']);
    });
  });
}
