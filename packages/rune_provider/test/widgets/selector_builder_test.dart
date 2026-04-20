import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_provider/src/widgets/selector_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SelectorBuilder', () {
    const b = SelectorBuilder();

    test('typeName is "Selector"', () {
      expect(b.typeName, 'Selector');
    });

    test('throws when selector is missing', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when selector is not a closure', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'selector': 'nope', 'builder': 'also-nope'},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
