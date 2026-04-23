import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('v1.20.0 geometry + color breadth through RuneView', () {
    testWidgets(
      'Color.fromARGB feeds a Container backgroundColor',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: RuneConfig.defaults(),
              source: '''
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 200, 100, 50),
                  ),
                )
              ''',
            ),
          ),
        );
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration! as BoxDecoration;
        expect(decoration.color, const Color.fromARGB(255, 200, 100, 50));
      },
    );

    testWidgets(
      'BorderRadius.only composes Radius.circular nested inside source',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: RuneConfig.defaults(),
              source: '''
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.elliptical(8, 4),
                    ),
                  ),
                )
              ''',
            ),
          ),
        );
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration! as BoxDecoration;
        expect(
          decoration.borderRadius,
          const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomRight: Radius.elliptical(8, 4),
          ),
        );
      },
    );

    testWidgets(
      'Positioned.fill stretches a coloured overlay inside a Stack',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SizedBox(
              width: 60,
              height: 60,
              child: RuneView(
                config: RuneConfig.defaults(),
                source: '''
                  Stack(
                    children: [
                      SizedBox(width: 60, height: 60),
                      Positioned.fill(
                        child: ColoredBox(color: Colors.red),
                      ),
                    ],
                  )
                ''',
              ),
            ),
          ),
        );
        expect(find.byType(Positioned), findsOneWidget);
        final positioned =
            tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.left, 0);
        expect(positioned.top, 0);
        expect(positioned.right, 0);
        expect(positioned.bottom, 0);
      },
    );

    testWidgets(
      'Color runtime properties are accessible from source',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: RuneConfig.defaults(),
              data: const {'accent': Color.fromARGB(255, 10, 20, 30)},
              source: r'''
                Column(
                  children: [
                    Text('r=${accent.red}'),
                    Text('g=${accent.green}'),
                    Text('b=${accent.blue}'),
                    Text('a=${accent.alpha}'),
                  ],
                )
              ''',
            ),
          ),
        );
        expect(find.text('r=10'), findsOneWidget);
        expect(find.text('g=20'), findsOneWidget);
        expect(find.text('b=30'), findsOneWidget);
        expect(find.text('a=255'), findsOneWidget);
      },
    );
  });
}
