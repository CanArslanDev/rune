import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/color_tween_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ColorTweenBuilder', () {
    const b = ColorTweenBuilder();

    test('typeName is "ColorTween"', () {
      expect(b.typeName, 'ColorTween');
      expect(b.constructorName, isNull);
    });

    test('begin/end both present plumbs through', () {
      final t = b.build(
        const ResolvedArguments(
          named: {
            'begin': Color(0xFF000000),
            'end': Color(0xFFFFFFFF),
          },
        ),
        testContext(),
      );
      expect(t, isA<ColorTween>());
      expect(t.begin, const Color(0xFF000000));
      expect(t.end, const Color(0xFFFFFFFF));
    });

    test('missing begin defaults to null', () {
      final t = b.build(
        const ResolvedArguments(named: {'end': Color(0xFF0000FF)}),
        testContext(),
      );
      expect(t.begin, isNull);
      expect(t.end, const Color(0xFF0000FF));
    });

    test('missing end defaults to null', () {
      final t = b.build(
        const ResolvedArguments(named: {'begin': Color(0xFFFF0000)}),
        testContext(),
      );
      expect(t.begin, const Color(0xFFFF0000));
      expect(t.end, isNull);
    });

    test('lerp at 0.5 produces a non-null mid color', () {
      final t = b.build(
        const ResolvedArguments(
          named: {
            'begin': Color(0xFF000000),
            'end': Color(0xFFFFFFFF),
          },
        ),
        testContext(),
      );
      final mid = t.transform(0.5);
      expect(mid, isNotNull);
    });
  });
}
