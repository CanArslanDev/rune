import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/edge_insets_ltrb_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('EdgeInsetsFromLTRBBuilder', () {
    const b = EdgeInsetsFromLTRBBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'EdgeInsets');
      expect(b.constructorName, 'fromLTRB');
    });

    test('builds with four positional values', () {
      final result = b.build(
        const ResolvedArguments(positional: [1, 2, 3, 4]),
        testContext(),
      );
      expect(result, const EdgeInsets.fromLTRB(1, 2, 3, 4));
    });

    test('accepts doubles', () {
      final result = b.build(
        const ResolvedArguments(positional: [0.5, 1.5, 2.5, 3.5]),
        testContext(),
      );
      expect(result, const EdgeInsets.fromLTRB(0.5, 1.5, 2.5, 3.5));
    });

    test('missing any positional throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(positional: [1, 2, 3]),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
