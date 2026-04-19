import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/slider_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('SliderBuilder', () {
    const b = SliderBuilder();

    test('typeName is "Slider"', () {
      expect(b.typeName, 'Slider');
    });

    testWidgets('renders with value: 0.5', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'value': 0.5}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(Slider), findsOneWidget);
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 0.5);
    });

    test('missing value throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('min/max/value plumb through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {'value': 50, 'min': 0, 'max': 100},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 50.0);
      expect(slider.min, 0.0);
      expect(slider.max, 100.0);
    });

    testWidgets('drag fires onChanged with a new double', (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'volumeChanged') captured.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': 0.1,
            'min': 0,
            'max': 1,
            'onChanged': 'volumeChanged',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pump();
      expect(captured, isNotEmpty);
      // Every dispatched arg list is a single double.
      final values = <double>[];
      for (final list in captured) {
        expect(list.length, 1);
        final first = list.first;
        expect(first, isA<double>());
        if (first is double) values.add(first);
      }
      for (final v in values) {
        expect(v, greaterThanOrEqualTo(0.0));
        expect(v, lessThanOrEqualTo(1.0));
      }
      // Last dispatched value should be greater than the starting value
      // (we dragged to the right).
      expect(values.last > 0.1, isTrue);
    });

    testWidgets('missing onChanged leaves callback null', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'value': 0.5}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.onChanged, isNull);
    });

    testWidgets('divisions and label plumb through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': 0.5,
            'divisions': 10,
            'label': 'Volume',
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.divisions, 10);
      expect(slider.label, 'Volume');
    });
  });
}
