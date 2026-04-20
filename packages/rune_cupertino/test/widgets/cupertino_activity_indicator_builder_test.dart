import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_activity_indicator_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoActivityIndicatorBuilder', () {
    const b = CupertinoActivityIndicatorBuilder();

    test('typeName is "CupertinoActivityIndicator"', () {
      expect(b.typeName, 'CupertinoActivityIndicator');
    });

    test('defaults to animating=true, radius=10', () {
      final w = b.build(
        ResolvedArguments.empty,
        testContext(),
      ) as CupertinoActivityIndicator;
      expect(w.animating, isTrue);
      expect(w.radius, 10.0);
    });

    test('animating=false is forwarded', () {
      final w = b.build(
        const ResolvedArguments(named: {'animating': false}),
        testContext(),
      ) as CupertinoActivityIndicator;
      expect(w.animating, isFalse);
    });

    test('radius is coerced from num to double', () {
      final w = b.build(
        const ResolvedArguments(named: {'radius': 16}),
        testContext(),
      ) as CupertinoActivityIndicator;
      expect(w.radius, 16.0);
    });

    test('color is forwarded', () {
      final w = b.build(
        const ResolvedArguments(named: {'color': Color(0xFFAABBCC)}),
        testContext(),
      ) as CupertinoActivityIndicator;
      expect(w.color, const Color(0xFFAABBCC));
    });
  });
}
