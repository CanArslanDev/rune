import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/size_transition_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SizeTransitionBuilder', () {
    const b = SizeTransitionBuilder();

    test('typeName is "SizeTransition"', () {
      expect(b.typeName, 'SizeTransition');
    });

    test(
        'sizeFactor + child plumb through with default axis and alignment',
        () {
      const anim = AlwaysStoppedAnimation<double>(1);
      const child = SizedBox(key: Key('k'));
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{'sizeFactor': anim, 'child': child},
        ),
        testContext(),
      ) as SizeTransition;
      expect(w.sizeFactor, same(anim));
      expect(w.child, same(child));
      expect(w.axis, Axis.vertical);
      expect(w.axisAlignment, 0.0);
    });

    test('axis plumbs through', () {
      const anim = AlwaysStoppedAnimation<double>(0.5);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'sizeFactor': anim,
            'axis': Axis.horizontal,
          },
        ),
        testContext(),
      ) as SizeTransition;
      expect(w.axis, Axis.horizontal);
    });

    test('axisAlignment plumbs through, coercing int to double', () {
      const anim = AlwaysStoppedAnimation<double>(0);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{'sizeFactor': anim, 'axisAlignment': -1},
        ),
        testContext(),
      ) as SizeTransition;
      expect(w.axisAlignment, -1.0);
    });

    test('missing sizeFactor throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('renders without error', (tester) async {
      const anim = AlwaysStoppedAnimation<double>(1);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'sizeFactor': anim,
            'child': Text('sz', textDirection: TextDirection.ltr),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: w),
      );
      expect(find.text('sz'), findsOneWidget);
    });
  });
}
