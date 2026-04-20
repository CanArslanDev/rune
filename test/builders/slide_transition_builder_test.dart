import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/slide_transition_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SlideTransitionBuilder', () {
    const b = SlideTransitionBuilder();

    test('typeName is "SlideTransition"', () {
      expect(b.typeName, 'SlideTransition');
    });

    test('position + child plumb through', () {
      const child = SizedBox(key: Key('k'));
      const anim = AlwaysStoppedAnimation<Offset>(Offset.zero);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'position': anim,
            'child': child,
          },
        ),
        testContext(),
      ) as SlideTransition;
      expect(w.position, same(anim));
      expect(w.child, same(child));
      expect(w.transformHitTests, isTrue);
    });

    test('transformHitTests defaults true; explicit false plumbs through', () {
      const anim = AlwaysStoppedAnimation<Offset>(Offset.zero);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'position': anim,
            'transformHitTests': false,
          },
        ),
        testContext(),
      ) as SlideTransition;
      expect(w.transformHitTests, isFalse);
    });

    test('textDirection plumbs through', () {
      const anim = AlwaysStoppedAnimation<Offset>(Offset.zero);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'position': anim,
            'textDirection': TextDirection.rtl,
          },
        ),
        testContext(),
      ) as SlideTransition;
      expect(w.textDirection, TextDirection.rtl);
    });

    test('missing position throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('renders without error', (tester) async {
      const anim = AlwaysStoppedAnimation<Offset>(Offset.zero);
      final w = b.build(
        const ResolvedArguments(
          named: <String, Object?>{
            'position': anim,
            'child': Text('slide', textDirection: TextDirection.ltr),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: w),
      );
      expect(find.text('slide'), findsOneWidget);
    });
  });
}
