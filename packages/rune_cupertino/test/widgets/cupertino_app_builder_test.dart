import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_app_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoAppBuilder', () {
    const b = CupertinoAppBuilder();

    test('typeName is "CupertinoApp"', () {
      expect(b.typeName, 'CupertinoApp');
    });

    test('builds with no args (empty title, debug banner default on)', () {
      final w = b.build(
        ResolvedArguments.empty,
        testContext(),
      ) as CupertinoApp;
      expect(w.home, isNull);
      expect(w.title, '');
      expect(w.debugShowCheckedModeBanner, isTrue);
    });

    test('forwards home, title, and debug banner override', () {
      const home = Text('Hello');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'home': home,
            'title': 'MyApp',
            'debugShowCheckedModeBanner': false,
          },
        ),
        testContext(),
      ) as CupertinoApp;
      expect(w.home, same(home));
      expect(w.title, 'MyApp');
      expect(w.debugShowCheckedModeBanner, isFalse);
    });

    test('theme is forwarded', () {
      const theme = CupertinoThemeData(brightness: Brightness.dark);
      final w = b.build(
        const ResolvedArguments(named: {'theme': theme}),
        testContext(),
      ) as CupertinoApp;
      expect(w.theme, same(theme));
    });

    testWidgets('renders home without exceptions', (tester) async {
      final w = b.build(
        const ResolvedArguments(
          named: {'home': Center(child: Text('hi'))},
        ),
        testContext(),
      );
      await tester.pumpWidget(w);
      expect(find.text('hi'), findsOneWidget);
    });
  });
}
