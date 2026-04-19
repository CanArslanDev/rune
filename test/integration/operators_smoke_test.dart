import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Operators smoke — binary and prefix evaluated in RuneView', () {
    testWidgets('SizedBox dimensions computed via *, +, and unary -',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              SizedBox(
                width: base * 2.5,
                height: -offset + margin,
                child: Text('ok'),
              )
            ''',
            config: RuneConfig.defaults(),
            data: const {
              'base': 10,
              'offset': 4,
              'margin': 20,
            },
          ),
        ),
      );

      // base * 2.5 → 25.0; -offset + margin → -4 + 20 = 16
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 25.0);
      expect(sizedBox.height, 16);
      expect(find.text('ok'), findsOneWidget);
    });

    testWidgets('modulo and division compute SizedBox dimensions',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              SizedBox(
                width: total / columns,
                height: total % columns,
                child: Text('grid'),
              )
            ''',
            config: RuneConfig.defaults(),
            data: const {
              'total': 100,
              'columns': 3,
            },
          ),
        ),
      );
      // total / columns → 100 / 3 = 33.333...
      // total % columns → 100 % 3 = 1
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, closeTo(33.333, 0.01));
      expect(sizedBox.height, 1);
      expect(find.text('grid'), findsOneWidget);
    });
  });
}
