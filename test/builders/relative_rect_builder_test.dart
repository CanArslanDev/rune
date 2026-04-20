import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/relative_rect_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('RelativeRectFromLTRBBuilder', () {
    const b = RelativeRectFromLTRBBuilder();

    test('typeName / constructorName', () {
      expect(b.typeName, 'RelativeRect');
      expect(b.constructorName, 'fromLTRB');
    });

    test('all four positionals coerce num to double', () {
      final rect = b.build(
        const ResolvedArguments(positional: [1, 2.5, 3, 4.0]),
        testContext(),
      );
      expect(rect.left, 1.0);
      expect(rect.top, 2.5);
      expect(rect.right, 3.0);
      expect(rect.bottom, 4.0);
    });

    test('missing positional raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(positional: [1, 2]),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-num positional raises a runtime TypeError', () {
      // `requirePositional<num>` defers the runtime type check to a cast,
      // which surfaces as TypeError rather than ArgumentException. Either
      // failure mode is acceptable for the source-author contract ("pass
      // four nums"); tests pin the current behaviour.
      expect(
        () => b.build(
          const ResolvedArguments(positional: [1, 2, 3, 'x']),
          testContext(),
        ),
        throwsA(isA<TypeError>()),
      );
    });

    test('equality with manually constructed RelativeRect', () {
      final rect = b.build(
        const ResolvedArguments(positional: [10, 20, 30, 40]),
        testContext(),
      );
      expect(rect, const RelativeRect.fromLTRB(10, 20, 30, 40));
    });
  });
}
