import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/animation_controller_spec.dart';

void main() {
  group('AnimationControllerSpec', () {
    test('defaults: lowerBound=0.0, upperBound=1.0, behavior=normal', () {
      const spec = AnimationControllerSpec(duration: Duration(seconds: 1));
      expect(spec.duration, const Duration(seconds: 1));
      expect(spec.lowerBound, 0.0);
      expect(spec.upperBound, 1.0);
      expect(spec.animationBehavior, AnimationBehavior.normal);
      expect(spec.reverseDuration, isNull);
      expect(spec.initialValue, isNull);
      expect(spec.debugLabel, isNull);
    });

    test('all fields plumb through constructor', () {
      const spec = AnimationControllerSpec(
        duration: Duration(seconds: 2),
        reverseDuration: Duration(seconds: 3),
        lowerBound: 0.1,
        upperBound: 0.9,
        animationBehavior: AnimationBehavior.preserve,
        initialValue: 0.5,
        debugLabel: 'test',
      );
      expect(spec.reverseDuration, const Duration(seconds: 3));
      expect(spec.lowerBound, 0.1);
      expect(spec.upperBound, 0.9);
      expect(spec.animationBehavior, AnimationBehavior.preserve);
      expect(spec.initialValue, 0.5);
      expect(spec.debugLabel, 'test');
    });

    test('is const-constructable', () {
      const a = AnimationControllerSpec(duration: Duration(seconds: 1));
      const b = AnimationControllerSpec(duration: Duration(seconds: 1));
      expect(identical(a, b), isTrue);
    });
  });
}
