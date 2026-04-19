import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/page_controller_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('PageControllerBuilder', () {
    const b = PageControllerBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'PageController');
      expect(b.constructorName, isNull);
    });

    test('no args constructs a default PageController', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, isA<PageController>());
      expect(result.initialPage, 0);
      expect(result.keepPage, isTrue);
      expect(result.viewportFraction, 1.0);
      result.dispose();
    });

    test('initialPage + viewportFraction plumb through', () {
      final result = b.build(
        const ResolvedArguments(
          named: {'initialPage': 3, 'viewportFraction': 0.85},
        ),
        testContext(),
      );
      expect(result.initialPage, 3);
      expect(result.viewportFraction, 0.85);
      result.dispose();
    });

    test('keepPage plumbs through', () {
      final result = b.build(
        const ResolvedArguments(named: {'keepPage': false}),
        testContext(),
      );
      expect(result.keepPage, isFalse);
      result.dispose();
    });
  });
}
