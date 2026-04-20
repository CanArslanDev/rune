import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/values/cupertino_theme_data_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoThemeDataBuilder', () {
    const b = CupertinoThemeDataBuilder();

    test('typeName is "CupertinoThemeData"', () {
      expect(b.typeName, 'CupertinoThemeData');
    });

    test('constructorName is null (default constructor)', () {
      expect(b.constructorName, isNull);
    });

    test('builds an empty CupertinoThemeData when no args', () {
      final theme = b.build(ResolvedArguments.empty, testContext());
      expect(theme, isA<CupertinoThemeData>());
    });

    test('brightness and primaryColor are forwarded', () {
      final theme = b.build(
        const ResolvedArguments(
          named: {
            'brightness': Brightness.dark,
            'primaryColor': Color(0xFFABCDEF),
          },
        ),
        testContext(),
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.primaryColor, const Color(0xFFABCDEF));
    });

    test('scaffoldBackgroundColor and barBackgroundColor forward', () {
      final theme = b.build(
        const ResolvedArguments(
          named: {
            'scaffoldBackgroundColor': Color(0xFF222222),
            'barBackgroundColor': Color(0xFF333333),
          },
        ),
        testContext(),
      );
      expect(theme.scaffoldBackgroundColor, const Color(0xFF222222));
      expect(theme.barBackgroundColor, const Color(0xFF333333));
    });
  });
}
