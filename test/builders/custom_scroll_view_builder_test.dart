import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/custom_scroll_view_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CustomScrollViewBuilder', () {
    const b = CustomScrollViewBuilder();

    test('typeName is "CustomScrollView"', () {
      expect(b.typeName, 'CustomScrollView');
    });

    testWidgets('renders with a single SliverToBoxAdapter child', (
      tester,
    ) async {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'slivers': <Object?>[
              SliverToBoxAdapter(child: Text('hello')),
            ],
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: w),
      );
      expect(find.text('hello'), findsOneWidget);
      expect(w, isA<CustomScrollView>());
    });

    test('missing slivers throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('scrollDirection + reverse + shrinkWrap + primary plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'slivers': <Object?>[],
            'scrollDirection': Axis.horizontal,
            'reverse': true,
            'shrinkWrap': true,
            'primary': false,
          },
        ),
        testContext(),
      ) as CustomScrollView;
      expect(w.scrollDirection, Axis.horizontal);
      expect(w.reverse, isTrue);
      expect(w.shrinkWrap, isTrue);
      expect(w.primary, isFalse);
    });

    test('empty slivers list renders', () {
      final w = b.build(
        const ResolvedArguments(named: {'slivers': <Object?>[]}),
        testContext(),
      ) as CustomScrollView;
      expect(w.slivers, isEmpty);
    });

    test('controller plumbs through to CustomScrollView.controller', () {
      final ctrl = ScrollController();
      addTearDown(ctrl.dispose);
      final w = b.build(
        ResolvedArguments(
          named: {
            'slivers': const <Object?>[],
            'controller': ctrl,
          },
        ),
        testContext(),
      ) as CustomScrollView;
      expect(identical(w.controller, ctrl), isTrue);
    });
  });
}
