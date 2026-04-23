import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/border_side_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BorderSideBuilder', () {
    const b = BorderSideBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'BorderSide');
      expect(b.constructorName, isNull);
    });

    test('default constructor matches Flutter defaults', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, const BorderSide());
    });

    test('color + width + style pass through', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'color': Color(0xFF00FF00),
            'width': 4,
            'style': BorderStyle.solid,
          },
        ),
        testContext(),
      );
      expect(
        result,
        const BorderSide(
          color: Color(0xFF00FF00),
          width: 4,
        ),
      );
    });

  });
}
