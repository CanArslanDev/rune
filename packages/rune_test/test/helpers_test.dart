import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune_test/rune_test.dart';

void main() {
  group('pumpRuneView', () {
    testWidgets('renders a trivial source string', (tester) async {
      await pumpRuneView(tester, "Text('hello')");
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('forwards data map', (tester) async {
      await pumpRuneView(
        tester,
        r"Text('Hello, $name!')",
        data: const {'name': 'Ali'},
      );
      expect(find.text('Hello, Ali!'), findsOneWidget);
    });

    testWidgets('forwards onEvent', (tester) async {
      final heard = <String>[];
      await pumpRuneView(
        tester,
        "ElevatedButton(onPressed: 'tap', child: Text('go'))",
        onEvent: (name, [_]) => heard.add(name),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      expect(heard, ['tap']);
    });

    testWidgets('custom wrap lets tests supply a different chrome',
        (tester) async {
      await pumpRuneView(
        tester,
        "Text('direct')",
        wrap: (child) => Directionality(
          textDirection: TextDirection.ltr,
          child: child,
        ),
      );
      expect(find.text('direct'), findsOneWidget);
    });
  });

  group('expectRuneRenders', () {
    testWidgets('pumps and asserts in one call', (tester) async {
      await expectRuneRenders(
        tester,
        "Text('nice')",
        find.text('nice'),
        findsOneWidget,
      );
    });

    testWidgets('data is forwarded', (tester) async {
      await expectRuneRenders(
        tester,
        r"Text('Hi $name')",
        find.text('Hi Ada'),
        findsOneWidget,
        data: const {'name': 'Ada'},
      );
    });
  });
}
