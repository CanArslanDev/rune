import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/theme_data_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ThemeDataBuilder', () {
    const b = ThemeDataBuilder();

    test('typeName/constructorName identify ThemeData default ctor', () {
      expect(b.typeName, 'ThemeData');
      expect(b.constructorName, isNull);
    });

    test('no args yields useMaterial3: true by default', () {
      final t = b.build(ResolvedArguments.empty, testContext());
      expect(t.useMaterial3, isTrue);
    });

    test('accepts a colorScheme override', () {
      final scheme = ColorScheme.fromSeed(
        seedColor: Colors.indigo,
      );
      final t = b.build(
        ResolvedArguments(
          named: {
            'colorScheme': scheme,
            'useMaterial3': false,
          },
        ),
        testContext(),
      );
      expect(t.colorScheme.primary, scheme.primary);
      expect(t.useMaterial3, isFalse);
    });

    test('accepts a brightness override alone', () {
      final t = b.build(
        const ResolvedArguments(
          named: {'brightness': Brightness.dark},
        ),
        testContext(),
      );
      expect(t.brightness, Brightness.dark);
    });

    test('accepts color overrides', () {
      final t = b.build(
        const ResolvedArguments(
          named: {
            'primaryColor': Colors.teal,
            'scaffoldBackgroundColor': Color(0xFFEEEEEE),
            'cardColor': Colors.white,
            'dividerColor': Colors.black12,
          },
        ),
        testContext(),
      );
      expect(t.primaryColor, Colors.teal);
      expect(t.scaffoldBackgroundColor, const Color(0xFFEEEEEE));
      expect(t.cardColor, Colors.white);
      expect(t.dividerColor, Colors.black12);
    });

    test('forwards materialTapTargetSize', () {
      final t = b.build(
        const ResolvedArguments(
          named: {
            'materialTapTargetSize': MaterialTapTargetSize.shrinkWrap,
          },
        ),
        testContext(),
      );
      expect(t.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
    });
  });
}
