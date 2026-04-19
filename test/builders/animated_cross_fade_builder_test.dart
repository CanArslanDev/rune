import 'package:flutter/material.dart'
    show Alignment, AnimatedCrossFade, CrossFadeState, Curves, Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/animated_cross_fade_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('AnimatedCrossFadeBuilder', () {
    const b = AnimatedCrossFadeBuilder();

    test('typeName is "AnimatedCrossFade"', () {
      expect(b.typeName, 'AnimatedCrossFade');
    });

    test('all required args plumb through with showFirst state', () {
      const first = Text('first');
      const second = Text('second');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'firstChild': first,
            'secondChild': second,
            'crossFadeState': CrossFadeState.showFirst,
            'duration': Duration(milliseconds: 250),
          },
        ),
        testContext(),
      ) as AnimatedCrossFade;
      expect(w.firstChild, same(first));
      expect(w.secondChild, same(second));
      expect(w.crossFadeState, CrossFadeState.showFirst);
      expect(w.duration, const Duration(milliseconds: 250));
      // Defaults.
      expect(w.firstCurve, same(Curves.linear));
      expect(w.secondCurve, same(Curves.linear));
      expect(w.sizeCurve, same(Curves.linear));
      expect(w.alignment, Alignment.topCenter);
      expect(w.reverseDuration, isNull);
    });

    test('missing firstChild throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'secondChild': Text('b'),
              'crossFadeState': CrossFadeState.showFirst,
              'duration': Duration(milliseconds: 100),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing secondChild throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'firstChild': Text('a'),
              'crossFadeState': CrossFadeState.showFirst,
              'duration': Duration(milliseconds: 100),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing crossFadeState throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'firstChild': Text('a'),
              'secondChild': Text('b'),
              'duration': Duration(milliseconds: 100),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing duration throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'firstChild': Text('a'),
              'secondChild': Text('b'),
              'crossFadeState': CrossFadeState.showFirst,
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('optional curves, alignment, reverseDuration plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'firstChild': Text('a'),
            'secondChild': Text('b'),
            'crossFadeState': CrossFadeState.showSecond,
            'duration': Duration(milliseconds: 200),
            'reverseDuration': Duration(milliseconds: 150),
            'firstCurve': Curves.easeIn,
            'secondCurve': Curves.easeOut,
            'sizeCurve': Curves.easeInOut,
            'alignment': Alignment.center,
          },
        ),
        testContext(),
      ) as AnimatedCrossFade;
      expect(w.crossFadeState, CrossFadeState.showSecond);
      expect(w.reverseDuration, const Duration(milliseconds: 150));
      expect(w.firstCurve, same(Curves.easeIn));
      expect(w.secondCurve, same(Curves.easeOut));
      expect(w.sizeCurve, same(Curves.easeInOut));
      expect(w.alignment, Alignment.center);
    });
  });
}
