import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/button_segment_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ButtonSegmentBuilder', () {
    const b = ButtonSegmentBuilder();

    test('typeName/constructorName identify the default ctor', () {
      expect(b.typeName, 'ButtonSegment');
      expect(b.constructorName, isNull);
    });

    test('builds a segment carrying value + label', () {
      const label = Text('A');
      final s = b.build(
        const ResolvedArguments(named: {'value': 1, 'label': label}),
        testContext(),
      );
      expect(s.value, 1);
      expect(s.label, same(label));
      expect(s.enabled, isTrue);
    });

    test('builds a segment with icon + tooltip', () {
      const icon = Icon(Icons.star);
      final s = b.build(
        const ResolvedArguments(
          named: {'value': 'star', 'icon': icon, 'tooltip': 'Favourite'},
        ),
        testContext(),
      );
      expect(s.icon, same(icon));
      expect(s.tooltip, 'Favourite');
    });

    test('enabled defaults true, respects override', () {
      final disabled = b.build(
        const ResolvedArguments(
          named: {'value': 1, 'label': Text('x'), 'enabled': false},
        ),
        testContext(),
      );
      expect(disabled.enabled, isFalse);
    });

    test('accepts an explicit null value (when label is supplied)', () {
      final s = b.build(
        const ResolvedArguments(
          named: {'value': null, 'label': Text('anon')},
        ),
        testContext(),
      );
      expect(s.value, isNull);
    });

    test(
      'omitting the value key entirely raises ArgumentException',
      () {
        expect(
          () => b.build(ResolvedArguments.empty, testContext()),
          throwsA(isA<ArgumentException>()),
        );
      },
    );
  });
}
