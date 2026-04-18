import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/text_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TextBuilder', () {
    const builder = TextBuilder();

    test('typeName is "Text"', () {
      expect(builder.typeName, 'Text');
    });

    test('builds a Text widget from positional string', () {
      final w = builder.build(
        const ResolvedArguments(positional: ['Hello']),
        testContext(),
      );
      expect(w, isA<Text>());
      expect((w as Text).data, 'Hello');
    });

    test('applies optional style', () {
      const style = TextStyle(fontSize: 20);
      final w = builder.build(
        const ResolvedArguments(
          positional: ['Hi'],
          named: {'style': style},
        ),
        testContext(),
      ) as Text;
      expect(w.style, same(style));
    });

    test('throws ArgumentException when positional missing', () {
      expect(
        () => builder.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
