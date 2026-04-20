import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/data_cell_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('DataCellBuilder', () {
    const b = DataCellBuilder();

    test('typeName and constructorName', () {
      expect(b.typeName, 'DataCell');
      expect(b.constructorName, isNull);
    });

    test('builds with positional child', () {
      const child = Text('alpha');
      final cell = b.build(
        const ResolvedArguments(positional: [child]),
        testContext(),
      );
      expect(cell, isA<DataCell>());
      expect(cell.child, same(child));
      expect(cell.onTap, isNull);
      expect(cell.showEditIcon, isFalse);
      expect(cell.placeholder, isFalse);
    });

    test('builds with named child', () {
      const child = Text('beta');
      final cell = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      );
      expect(cell.child, same(child));
    });

    test('missing child throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('showEditIcon and placeholder are forwarded', () {
      final cell = b.build(
        const ResolvedArguments(
          positional: [Text('x')],
          named: {'showEditIcon': true, 'placeholder': true},
        ),
        testContext(),
      );
      expect(cell.showEditIcon, isTrue);
      expect(cell.placeholder, isTrue);
    });

    test('onTap as event name dispatches with no args', () {
      final events = RuneEventDispatcher();
      final fired = <String>[];
      events.setCatchAllHandler((n, _) => fired.add(n));
      final cell = b.build(
        const ResolvedArguments(
          positional: [Text('x')],
          named: {'onTap': 'cellTapped'},
        ),
        testContext(events: events),
      );
      expect(cell.onTap, isNotNull);
      cell.onTap!.call();
      expect(fired, ['cellTapped']);
    });
  });
}
