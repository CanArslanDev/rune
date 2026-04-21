import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_riverpod/src/widgets/provider_scope_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ProviderScopeBuilder', () {
    const b = ProviderScopeBuilder();

    test('typeName is "ProviderScope"', () {
      expect(b.typeName, 'ProviderScope');
    });

    test('throws when child is missing', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('builds a ProviderScope widget', () {
      final widget = b.build(
        const ResolvedArguments(named: {'child': SizedBox.shrink()}),
        testContext(),
      );
      expect(widget, isA<ProviderScope>());
    });
  });
}
