import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('v1.21.0 borders + gradients + time breadth through RuneView', () {
    testWidgets(
      'Border.all(color: ..., width: ...) composes a BoxDecoration border',
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
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                )
              ''',
            ),
          ),
        );
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration! as BoxDecoration;
        final border = decoration.border! as Border;
        expect(border.top.color, Colors.red);
        expect(border.top.width, 3.0);
      },
    );

    testWidgets(
      'LinearGradient with Alignment + TileMode constants renders',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: RuneConfig.defaults(),
              source: '''
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.red, Colors.blue],
                      tileMode: TileMode.clamp,
                    ),
                  ),
                )
              ''',
            ),
          ),
        );
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration! as BoxDecoration;
        final gradient = decoration.gradient! as LinearGradient;
        expect(gradient.colors, [Colors.red, Colors.blue]);
        expect(gradient.begin, Alignment.topLeft);
        expect(gradient.end, Alignment.bottomRight);
      },
    );

    testWidgets(
      'Duration runtime properties drive source-level text',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: RuneConfig.defaults(),
              data: const {'elapsed': Duration(hours: 1, minutes: 30)},
              source: r'''
                Column(
                  children: [
                    Text('minutes=${elapsed.inMinutes}'),
                    Text('seconds=${elapsed.inSeconds}'),
                  ],
                )
              ''',
            ),
          ),
        );
        expect(find.text('minutes=90'), findsOneWidget);
        expect(find.text('seconds=5400'), findsOneWidget);
      },
    );

    testWidgets(
      'DateTime fields + methods compose in source',
      (tester) async {
        final past = DateTime.utc(2025);
        final now = DateTime.utc(2026, 1, 11);
        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: RuneConfig.defaults(),
              data: {'now': now, 'past': past},
              source: r'''
                Column(
                  children: [
                    Text('year=${now.year}'),
                    Text('days=${now.difference(past).inDays}'),
                  ],
                )
              ''',
            ),
          ),
        );
        expect(find.text('year=2026'), findsOneWidget);
        expect(find.text('days=375'), findsOneWidget);
      },
    );
  });
}
