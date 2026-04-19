import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/snack_bar_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SnackBarBuilder', () {
    const b = SnackBarBuilder();

    test('typeName is "SnackBar" and constructorName is null', () {
      expect(b.typeName, 'SnackBar');
      expect(b.constructorName, isNull);
    });

    test('missing content raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('content plumbs through', () {
      const content = Text('Message');
      final sb = b.build(
        const ResolvedArguments(named: {'content': content}),
        testContext(),
      );
      expect(sb.content, same(content));
    });

    test('backgroundColor, duration, behavior, elevation plumb through', () {
      final sb = b.build(
        const ResolvedArguments(
          named: {
            'content': Text('X'),
            'backgroundColor': Color(0xFF0055AA),
            'duration': Duration(seconds: 2),
            'behavior': SnackBarBehavior.floating,
            'elevation': 6,
          },
        ),
        testContext(),
      );
      expect(sb.backgroundColor, const Color(0xFF0055AA));
      expect(sb.duration, const Duration(seconds: 2));
      expect(sb.behavior, SnackBarBehavior.floating);
      expect(sb.elevation, 6.0);
    });

    test('margin, padding, showCloseIcon plumb through', () {
      final sb = b.build(
        const ResolvedArguments(
          named: {
            'content': Text('X'),
            'margin': EdgeInsets.all(12),
            'padding': EdgeInsets.all(6),
            'showCloseIcon': true,
          },
        ),
        testContext(),
      );
      expect(sb.margin, const EdgeInsets.all(12));
      expect(sb.padding, const EdgeInsets.all(6));
      expect(sb.showCloseIcon, isTrue);
    });

    test('duration defaults to the standard 4-second display duration', () {
      final sb = b.build(
        const ResolvedArguments(named: {'content': Text('X')}),
        testContext(),
      );
      expect(sb.duration, const Duration(milliseconds: 4000));
    });
  });
}
