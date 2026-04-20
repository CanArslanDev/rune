import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/rotation_transition_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('RotationTransitionBuilder', () {
    const b = RotationTransitionBuilder();

    test('typeName is "RotationTransition"', () {
      expect(b.typeName, 'RotationTransition');
    });

    test('turns + child plumb through', () {
      const anim = AlwaysStoppedAnimation<double>(0.25);
      const child = SizedBox(key: Key('k'));
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{'turns': anim, 'child': child},
        ),
        testContext(),
      ) as RotationTransition;
      expect(w.turns, same(anim));
      expect(w.child, same(child));
      expect(w.alignment, Alignment.center);
    });

    test('alignment plumbs through', () {
      const anim = AlwaysStoppedAnimation<double>(0);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'turns': anim,
            'alignment': Alignment.bottomRight,
          },
        ),
        testContext(),
      ) as RotationTransition;
      expect(w.alignment, Alignment.bottomRight);
    });

    test('filterQuality plumbs through', () {
      const anim = AlwaysStoppedAnimation<double>(0);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'turns': anim,
            'filterQuality': FilterQuality.medium,
          },
        ),
        testContext(),
      ) as RotationTransition;
      expect(w.filterQuality, FilterQuality.medium);
    });

    test('missing turns throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('renders without error', (tester) async {
      const anim = AlwaysStoppedAnimation<double>(0);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'turns': anim,
            'child': Text('rot', textDirection: TextDirection.ltr),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: w),
      );
      expect(find.text('rot'), findsOneWidget);
    });
  });
}
