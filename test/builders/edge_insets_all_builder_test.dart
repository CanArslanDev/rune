import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/edge_insets_all_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('EdgeInsetsAllBuilder', () {
    const b = EdgeInsetsAllBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'EdgeInsets');
      expect(b.constructorName, 'all');
    });

    test('builds EdgeInsets.all from positional int', () {
      final result = b.build(
        const ResolvedArguments(positional: [16]),
        testContext(),
      );
      expect(result, equals(const EdgeInsets.all(16)));
    });

    test('builds EdgeInsets.all from positional double', () {
      final result = b.build(
        const ResolvedArguments(positional: [12.5]),
        testContext(),
      );
      expect(result, equals(const EdgeInsets.all(12.5)));
    });

    test('throws on missing positional', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
