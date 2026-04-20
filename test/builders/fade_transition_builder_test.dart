import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/fade_transition_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FadeTransitionBuilder', () {
    const b = FadeTransitionBuilder();

    test('typeName is "FadeTransition"', () {
      expect(b.typeName, 'FadeTransition');
    });

    test('opacity + child plumb through', () {
      const child = SizedBox(key: Key('k'));
      const anim = AlwaysStoppedAnimation<double>(0.5);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'opacity': anim,
            'child': child,
          },
        ),
        testContext(),
      ) as FadeTransition;
      expect(w.opacity, same(anim));
      expect(w.child, same(child));
      expect(w.alwaysIncludeSemantics, isFalse);
    });

    test('alwaysIncludeSemantics plumbs through', () {
      const anim = AlwaysStoppedAnimation<double>(1);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'opacity': anim,
            'alwaysIncludeSemantics': true,
          },
        ),
        testContext(),
      ) as FadeTransition;
      expect(w.alwaysIncludeSemantics, isTrue);
    });

    test('child is optional', () {
      const anim = AlwaysStoppedAnimation<double>(0);
      final w = b.build(
        const ResolvedArguments(named: <String, Object?>{'opacity': anim}),
        testContext(),
      ) as FadeTransition;
      expect(w.child, isNull);
    });

    test('missing opacity throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('renders without error and forwards opacity', (tester) async {
      const anim = AlwaysStoppedAnimation<double>(0.25);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'opacity': anim,
            'child': Text('fade', textDirection: TextDirection.ltr),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: w,
        ),
      );
      expect(find.text('fade'), findsOneWidget);
    });
  });
}
