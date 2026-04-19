import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/text_editing_controller_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TextEditingControllerBuilder', () {
    const b = TextEditingControllerBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'TextEditingController');
      expect(b.constructorName, isNull);
    });

    test('no args constructs a TextEditingController with empty text', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, isA<TextEditingController>());
      expect(result.text, '');
      result.dispose();
    });

    test('text arg plumbs through', () {
      final result = b.build(
        const ResolvedArguments(named: {'text': 'hello'}),
        testContext(),
      );
      expect(result.text, 'hello');
      result.dispose();
    });

    test('result is a TextEditingController instance', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, isA<TextEditingController>());
      result.dispose();
    });
  });
}
