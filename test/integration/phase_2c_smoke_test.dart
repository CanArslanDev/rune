import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('Phase 2c integration', () {
    testWidgets('Padding wraps child', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Padding(padding: EdgeInsets.all(16), child: Text('x'))
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final p = tester.widget<Padding>(find.byType(Padding).first);
      expect(p.padding, const EdgeInsets.all(16));
    });

    testWidgets('Center with factor', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Center(widthFactor: 2, child: Text('x'))
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final c = tester.widget<Center>(find.byType(Center).first);
      expect(c.widthFactor, 2.0);
    });

    testWidgets('Stack + Alignment.center', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Stack(
            alignment: Alignment.center,
            children: [Text('a'), Text('b')],
          )
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final s = tester.widget<Stack>(find.byType(Stack).first);
      expect(s.alignment, Alignment.center);
      expect(s.children.length, 2);
    });

    testWidgets('Row with Expanded children', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Row(children: [
            Expanded(child: Text('left')),
            Expanded(flex: 2, child: Text('right')),
          ])
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final expandeds = tester
          .widgetList<Expanded>(find.byType(Expanded))
          .toList(growable: false);
      expect(expandeds.length, 2);
      expect(expandeds[0].flex, 1);
      expect(expandeds[1].flex, 2);
    });

    testWidgets('Flexible with FlexFit.tight', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Row(children: [Flexible(fit: FlexFit.tight, child: Text('x'))])
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final f = tester.widget<Flexible>(find.byType(Flexible).first);
      expect(f.fit, FlexFit.tight);
    });

    testWidgets('Card with elevation + color', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Card(
            elevation: 4,
            color: Color(0xFFAAAAAA),
            child: Padding(padding: EdgeInsets.all(8), child: Text('x')),
          )
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final c = tester.widget<Card>(find.byType(Card).first);
      expect(c.elevation, 4.0);
      expect(c.color, const Color(0xFFAAAAAA));
    });

    testWidgets('Icon with Icons.home + size + color', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Icon(Icons.home, size: 32, color: Color(0xFF00FF00))
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final ic = tester.widget<Icon>(find.byType(Icon).first);
      expect(ic.icon, Icons.home);
      expect(ic.size, 32.0);
      expect(ic.color, const Color(0xFF00FF00));
    });

    testWidgets('Image.asset (structural parse)', (tester) async {
      // Suppress the "asset not found" error that fires during image loading;
      // the test only verifies structural widget properties, not pixel content.
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains('Unable to load asset')) {
          return; // swallow expected missing-asset error
        }
        originalOnError?.call(details);
      };
      try {
        await tester.pumpWidget(_wrap(RuneView(
          source: "Image.asset('assets/demo.png', width: 48, height: 48)",
          config: RuneConfig.defaults(),
        ),),);
        final img = tester.widget<Image>(find.byType(Image).first);
        expect(img.image, isA<AssetImage>());
        expect((img.image as AssetImage).assetName, 'assets/demo.png');
        expect(img.width, 48.0);
      } finally {
        FlutterError.onError = originalOnError;
      }
    });

    testWidgets('ListView with static children + shrinkWrap', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          ListView(
            shrinkWrap: true,
            children: [Text('a'), Text('b'), Text('c')],
          )
        ''',
        config: RuneConfig.defaults(),
      ),),);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
    });

    testWidgets('Scaffold + AppBar + body', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Scaffold(
            appBar: AppBar(
              title: Text('Demo'),
              backgroundColor: Color(0xFF2196F3),
            ),
            body: Center(child: Text('body')),
          )
        ''',
        config: RuneConfig.defaults(),
      ),),);
      expect(find.text('Demo'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, const Color(0xFF2196F3));
    });
  });
}
