import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/curved_animation_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CurvedAnimationBuilder', () {
    const b = CurvedAnimationBuilder();

    test('typeName is "CurvedAnimation"', () {
      expect(b.typeName, 'CurvedAnimation');
      expect(b.constructorName, isNull);
    });

    test('parent + curve construct a CurvedAnimation', () {
      const parent = AlwaysStoppedAnimation<double>(0.3);
      final c = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'parent': parent,
            'curve': Curves.easeIn,
          },
        ),
        testContext(),
      );
      expect(c, isA<CurvedAnimation>());
      expect(c.parent, same(parent));
      expect(c.curve, same(Curves.easeIn));
      expect(c.reverseCurve, isNull);
    });

    test('reverseCurve plumbs through', () {
      const parent = AlwaysStoppedAnimation<double>(0);
      final c = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'parent': parent,
            'curve': Curves.linear,
            'reverseCurve': Curves.easeOut,
          },
        ),
        testContext(),
      );
      expect(c.reverseCurve, same(Curves.easeOut));
    });

    test('missing parent throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'curve': Curves.linear}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing curve throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: <String, Object?>{
              'parent': AlwaysStoppedAnimation<double>(0),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
