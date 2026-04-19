import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/animated_size_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('AnimatedSizeBuilder', () {
    const b = AnimatedSizeBuilder();

    test('typeName is "AnimatedSize"', () {
      expect(b.typeName, 'AnimatedSize');
    });

    test('required duration + child plumb through', () {
      const child = Text('content');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(milliseconds: 300),
            'child': child,
          },
        ),
        testContext(),
      ) as AnimatedSize;
      expect(w.duration, const Duration(milliseconds: 300));
      expect(w.child, same(child));
      // Defaults.
      expect(w.curve, same(Curves.linear));
      expect(w.alignment, Alignment.center);
      expect(w.reverseDuration, isNull);
    });

    test('missing duration throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('curve, alignment, reverseDuration plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(milliseconds: 200),
            'reverseDuration': Duration(milliseconds: 150),
            'curve': Curves.easeInOut,
            'alignment': Alignment.topLeft,
          },
        ),
        testContext(),
      ) as AnimatedSize;
      expect(w.reverseDuration, const Duration(milliseconds: 150));
      expect(w.curve, same(Curves.easeInOut));
      expect(w.alignment, Alignment.topLeft);
    });
  });
}
