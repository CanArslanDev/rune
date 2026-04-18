import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('Phase 2b integration', () {
    testWidgets('EdgeInsets.symmetric padding applies', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('x'),
          )
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final c = tester.widget<Container>(find.byType(Container));
      expect(
        c.padding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    });

    testWidgets('EdgeInsets.only partial padding applies', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Container(
            padding: EdgeInsets.only(left: 4, top: 8),
            child: Text('x'),
          )
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final c = tester.widget<Container>(find.byType(Container));
      expect(c.padding, const EdgeInsets.only(left: 4, top: 8));
    });

    testWidgets('EdgeInsets.fromLTRB padding applies', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Container(
            padding: EdgeInsets.fromLTRB(1, 2, 3, 4),
            child: Text('x'),
          )
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final c = tester.widget<Container>(find.byType(Container));
      expect(c.padding, const EdgeInsets.fromLTRB(1, 2, 3, 4));
    });

    testWidgets(
      'Text picks up TextStyle with fontSize + color + weight',
      (tester) async {
        await tester.pumpWidget(_wrap(RuneView(
          source: '''
            Text(
              'Hello',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFFFF0000),
                fontWeight: FontWeight.bold,
              ),
            )
          ''',
          config: RuneConfig.defaults(),
        ),),);
        final textWidget = tester.widget<Text>(find.text('Hello'));
        expect(textWidget.style?.fontSize, 20.0);
        expect(textWidget.style?.color, const Color(0xFFFF0000));
        expect(textWidget.style?.fontWeight, FontWeight.bold);
      },
    );

    testWidgets('Color(hex) as Container color', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Container(
            color: Color(0xFF00FF00),
            child: Text('x'),
          )
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final c = tester.widget<Container>(find.byType(Container));
      expect(c.color, const Color(0xFF00FF00));
    });

    testWidgets(
      'BoxDecoration with color + BorderRadius.circular on Container',
      (tester) async {
        await tester.pumpWidget(_wrap(RuneView(
          source: '''
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('x'),
            )
          ''',
          config: RuneConfig.defaults(),
        ),),);
        final c = tester.widget<Container>(find.byType(Container));
        final decoration = c.decoration! as BoxDecoration;
        expect(decoration.color, Colors.red);
        expect(decoration.borderRadius, BorderRadius.circular(12));
        expect(decoration.shape, BoxShape.rectangle);
      },
    );

    testWidgets(
      'BoxDecoration shape circle via BoxShape.circle constant',
      (tester) async {
        await tester.pumpWidget(_wrap(RuneView(
          source: '''
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text('x'),
            )
          ''',
          config: RuneConfig.defaults(),
        ),),);
        final c = tester.widget<Container>(find.byType(Container));
        final decoration = c.decoration! as BoxDecoration;
        expect(decoration.shape, BoxShape.circle);
      },
    );

    testWidgets(
      'compound: Container with padding + decoration + styled Text child',
      (tester) async {
        await tester.pumpWidget(_wrap(RuneView(
          source: '''
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Styled',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ''',
          config: RuneConfig.defaults(),
        ),),);
        final c = tester.widget<Container>(find.byType(Container));
        expect(
          c.padding,
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
        final deco = c.decoration! as BoxDecoration;
        expect(deco.color, const Color(0xFF2196F3));
        expect(deco.borderRadius, BorderRadius.circular(8));
        final styled = tester.widget<Text>(find.text('Styled'));
        expect(styled.style?.fontSize, 18.0);
        expect(styled.style?.color, Colors.white);
        expect(styled.style?.fontWeight, FontWeight.w600);
      },
    );
  });
}
