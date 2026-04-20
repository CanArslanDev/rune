import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/scale_transition_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ScaleTransitionBuilder', () {
    const b = ScaleTransitionBuilder();

    test('typeName is "ScaleTransition"', () {
      expect(b.typeName, 'ScaleTransition');
    });

    test('scale + child plumb through with default alignment', () {
      const anim = AlwaysStoppedAnimation<double>(1);
      const child = SizedBox(key: Key('k'));
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{'scale': anim, 'child': child},
        ),
        testContext(),
      ) as ScaleTransition;
      expect(w.scale, same(anim));
      expect(w.child, same(child));
      expect(w.alignment, Alignment.center);
    });

    test('custom alignment plumbs through', () {
      const anim = AlwaysStoppedAnimation<double>(0.5);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'scale': anim,
            'alignment': Alignment.topLeft,
          },
        ),
        testContext(),
      ) as ScaleTransition;
      expect(w.alignment, Alignment.topLeft);
    });

    test('filterQuality plumbs through', () {
      const anim = AlwaysStoppedAnimation<double>(0);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'scale': anim,
            'filterQuality': FilterQuality.high,
          },
        ),
        testContext(),
      ) as ScaleTransition;
      expect(w.filterQuality, FilterQuality.high);
    });

    test('missing scale throws ArgumentException', () {
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
            'scale': anim,
            'child': Text('scale', textDirection: TextDirection.ltr),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: w),
      );
      expect(find.text('scale'), findsOneWidget);
    });
  });
}
