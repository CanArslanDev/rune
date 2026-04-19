import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/focus_node_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FocusNodeBuilder', () {
    const b = FocusNodeBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'FocusNode');
      expect(b.constructorName, isNull);
    });

    test('no args constructs a default FocusNode', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, isA<FocusNode>());
      expect(result.skipTraversal, isFalse);
      expect(result.canRequestFocus, isTrue);
      expect(result.descendantsAreFocusable, isTrue);
      expect(result.descendantsAreTraversable, isTrue);
      result.dispose();
    });

    test('debugLabel plumbs through', () {
      final result = b.build(
        const ResolvedArguments(named: {'debugLabel': 'field-a'}),
        testContext(),
      );
      expect(result.debugLabel, 'field-a');
      result.dispose();
    });

    test('skipTraversal + canRequestFocus plumb through', () {
      final result = b.build(
        const ResolvedArguments(
          named: {'skipTraversal': true, 'canRequestFocus': false},
        ),
        testContext(),
      );
      expect(result.skipTraversal, isTrue);
      expect(result.canRequestFocus, isFalse);
      result.dispose();
    });
  });
}
