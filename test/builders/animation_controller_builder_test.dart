import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/animation_controller_builder.dart';
import 'package:rune/src/core/animation_controller_spec.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('AnimationControllerBuilder', () {
    const b = AnimationControllerBuilder();

    test('typeName is "AnimationController" and constructorName is null', () {
      expect(b.typeName, 'AnimationController');
      expect(b.constructorName, isNull);
    });

    test('duration alone yields a spec with sensible defaults', () {
      final spec = b.build(
        const ResolvedArguments(
          named: {'duration': Duration(seconds: 1)},
        ),
        testContext(),
      );
      expect(spec, isA<AnimationControllerSpec>());
      expect(spec.duration, const Duration(seconds: 1));
      expect(spec.reverseDuration, isNull);
      expect(spec.lowerBound, 0.0);
      expect(spec.upperBound, 1.0);
      expect(spec.animationBehavior, AnimationBehavior.normal);
      expect(spec.initialValue, isNull);
      expect(spec.debugLabel, isNull);
    });

    test('all optional args plumb through', () {
      final spec = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(seconds: 2),
            'reverseDuration': Duration(seconds: 3),
            'lowerBound': 0.25,
            'upperBound': 0.75,
            'value': 0.5,
            'debugLabel': 'spin',
          },
        ),
        testContext(),
      );
      expect(spec.duration, const Duration(seconds: 2));
      expect(spec.reverseDuration, const Duration(seconds: 3));
      expect(spec.lowerBound, 0.25);
      expect(spec.upperBound, 0.75);
      expect(spec.initialValue, 0.5);
      expect(spec.debugLabel, 'spin');
    });

    test('integer lowerBound / upperBound coerce to double', () {
      final spec = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(seconds: 1),
            'lowerBound': 0,
            'upperBound': 2,
          },
        ),
        testContext(),
      );
      expect(spec.lowerBound, 0.0);
      expect(spec.upperBound, 2.0);
    });

    test('missing duration throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
