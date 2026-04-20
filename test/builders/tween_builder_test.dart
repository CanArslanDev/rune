import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/tween_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TweenBuilder', () {
    const b = TweenBuilder();

    test('typeName is "Tween"', () {
      expect(b.typeName, 'Tween');
      expect(b.constructorName, isNull);
    });

    test('numeric begin/end lerp at 0.5 yields midpoint', () {
      final t = b.build(
        const ResolvedArguments(named: {'begin': 0.0, 'end': 10.0}),
        testContext(),
      );
      // ignore: avoid_dynamic_calls, cast_nullable_to_non_nullable
      expect((t.transform(0) as num).toDouble(), 0.0);
      // ignore: avoid_dynamic_calls, cast_nullable_to_non_nullable
      expect((t.transform(0.5) as num).toDouble(), 5.0);
      // ignore: avoid_dynamic_calls, cast_nullable_to_non_nullable
      expect((t.transform(1) as num).toDouble(), 10.0);
    });

    test('absent begin/end default to null', () {
      final t = b.build(ResolvedArguments.empty, testContext());
      expect(t, isA<Tween<Object?>>());
      expect(t.begin, isNull);
      expect(t.end, isNull);
    });

    test('only begin present; end is null', () {
      final t = b.build(
        const ResolvedArguments(named: {'begin': 1.0}),
        testContext(),
      );
      expect(t.begin, 1.0);
      expect(t.end, isNull);
    });

    test('Offset tween lerps componentwise', () {
      final t = b.build(
        const ResolvedArguments(
          named: {'begin': Offset.zero, 'end': Offset(10, 20)},
        ),
        testContext(),
      );
      // ignore: cast_nullable_to_non_nullable
      final mid = t.transform(0.5) as Offset;
      expect(mid.dx, 5.0);
      expect(mid.dy, 10.0);
    });
  });
}
