import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/chip_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ChipBuilder', () {
    const b = ChipBuilder();

    test('typeName is "Chip"', () {
      expect(b.typeName, 'Chip');
    });

    testWidgets('required label renders visible text', (tester) async {
      final w = b.build(
        const ResolvedArguments(named: {'label': Text('Tag')}),
        testContext(),
      ) as Chip;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: w)),
      );
      expect(find.text('Tag'), findsOneWidget);
    });

    test('missing label throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('onDeleted dispatches event', () {
      final events = RuneEventDispatcher();
      var count = 0;
      events.register('removeTag', () => count++);
      final w = b.build(
        const ResolvedArguments(
          named: {'label': Text('Tag'), 'onDeleted': 'removeTag'},
        ),
        testContext(events: events),
      ) as Chip;

      expect(w.onDeleted, isNotNull);
      w.onDeleted!.call();
      expect(count, 1);
    });

    test('avatar/backgroundColor/labelStyle plumb through', () {
      const avatar = Icon(Icons.person);
      const style = TextStyle(fontSize: 14, color: Color(0xFF000000));
      final w = b.build(
        const ResolvedArguments(
          named: {
            'label': Text('Tag'),
            'avatar': avatar,
            'backgroundColor': Color(0xFFEEEEEE),
            'labelStyle': style,
          },
        ),
        testContext(),
      ) as Chip;
      expect(w.avatar, same(avatar));
      expect(w.backgroundColor, const Color(0xFFEEEEEE));
      expect(w.labelStyle, style);
    });
  });
}
