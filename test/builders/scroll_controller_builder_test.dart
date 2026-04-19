import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/scroll_controller_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ScrollControllerBuilder', () {
    const b = ScrollControllerBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'ScrollController');
      expect(b.constructorName, isNull);
    });

    test('no args constructs a default ScrollController', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, isA<ScrollController>());
      expect(result.initialScrollOffset, 0.0);
      expect(result.keepScrollOffset, isTrue);
      expect(result.debugLabel, isNull);
      result.dispose();
    });

    test('initialScrollOffset plumbs through', () {
      final result = b.build(
        const ResolvedArguments(named: {'initialScrollOffset': 42.0}),
        testContext(),
      );
      expect(result.initialScrollOffset, 42.0);
      result.dispose();
    });

    test('keepScrollOffset + debugLabel plumb through', () {
      final result = b.build(
        const ResolvedArguments(
          named: {'keepScrollOffset': false, 'debugLabel': 'list-a'},
        ),
        testContext(),
      );
      expect(result.keepScrollOffset, isFalse);
      expect(result.debugLabel, 'list-a');
      result.dispose();
    });
  });
}
