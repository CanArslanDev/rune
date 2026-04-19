import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/animated_container_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('AnimatedContainerBuilder', () {
    const b = AnimatedContainerBuilder();

    test('typeName is "AnimatedContainer"', () {
      expect(b.typeName, 'AnimatedContainer');
    });

    test('required duration plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'duration': Duration(milliseconds: 300)},
        ),
        testContext(),
      ) as AnimatedContainer;
      expect(w.duration, const Duration(milliseconds: 300));
    });

    test('curve defaults to Curves.linear when omitted', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'duration': Duration(milliseconds: 200)},
        ),
        testContext(),
      ) as AnimatedContainer;
      expect(w.curve, same(Curves.linear));
    });

    test('curve argument plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(milliseconds: 200),
            'curve': Curves.easeInOut,
          },
        ),
        testContext(),
      ) as AnimatedContainer;
      expect(w.curve, same(Curves.easeInOut));
    });

    test('container slots plumb through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(milliseconds: 100),
            'width': 100,
            'height': 50,
            'color': Color(0xFFABCDEF),
            'padding': EdgeInsets.all(8),
            'margin': EdgeInsets.all(4),
            'alignment': Alignment.center,
            'child': child,
          },
        ),
        testContext(),
      ) as AnimatedContainer;
      expect(w.constraints!.minWidth, 100);
      expect(w.constraints!.minHeight, 50);
      // AnimatedContainer wraps `color` into a BoxDecoration internally.
      expect((w.decoration as BoxDecoration?)?.color,
          const Color(0xFFABCDEF),);
      expect(w.padding, const EdgeInsets.all(8));
      expect(w.margin, const EdgeInsets.all(4));
      expect(w.alignment, Alignment.center);
      expect(w.child, same(child));
    });

    test('decoration slot plumbs through', () {
      const decoration = BoxDecoration(color: Color(0xFF112233));
      final w = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(milliseconds: 50),
            'decoration': decoration,
          },
        ),
        testContext(),
      ) as AnimatedContainer;
      expect(w.decoration, decoration);
    });

    test('missing duration throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
