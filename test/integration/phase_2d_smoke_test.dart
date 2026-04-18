import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Phase 2d integration — buttons + events', () {
    testWidgets('ElevatedButton tap fires widget.onEvent', (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(RuneView(
        source: "ElevatedButton(onPressed: 'submit', child: Text('Send'))",
        config: RuneConfig.defaults(),
        onEvent: (name, [args]) => captured = name,
      ),),);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(captured, 'submit');
    });

    testWidgets('ElevatedButton without onPressed is disabled',
        (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: "ElevatedButton(child: Text('Send'))",
        config: RuneConfig.defaults(),
      ),),);
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('TextButton tap fires widget.onEvent', (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(RuneView(
        source: "TextButton(onPressed: 'cancel', child: Text('Cancel'))",
        config: RuneConfig.defaults(),
        onEvent: (name, [args]) => captured = name,
      ),),);
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(captured, 'cancel');
    });

    testWidgets('IconButton tap fires widget.onEvent', (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(RuneView(
        source: "IconButton(onPressed: 'close', icon: Icon(Icons.close))",
        config: RuneConfig.defaults(),
        onEvent: (name, [args]) => captured = name,
      ),),);
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(captured, 'close');
    });

    testWidgets('multiple buttons route distinct events', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Row(children: [
            ElevatedButton(onPressed: 'one', child: Text('1')),
            TextButton(onPressed: 'two', child: Text('2')),
            IconButton(onPressed: 'three', icon: Icon(Icons.star)),
          ])
        ''',
        config: RuneConfig.defaults(),
        onEvent: (name, [args]) => log.add(name),
      ),),);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(log, ['one', 'two', 'three']);
    });

    testWidgets('button in a Scaffold + AppBar flow', (tester) async {
      String? captured;
      await tester.pumpWidget(MaterialApp(
        home: RuneView(
          source: '''
            Scaffold(
              appBar: AppBar(
                title: Text('Demo'),
                actions: [
                  IconButton(onPressed: 'search', icon: Icon(Icons.search)),
                ],
              ),
              body: Center(
                child: ElevatedButton(
                  onPressed: 'primary',
                  child: Text('Do the thing'),
                ),
              ),
            )
          ''',
          config: RuneConfig.defaults(),
          onEvent: (name, [args]) => captured = name,
        ),
      ),);
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(captured, 'search');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(captured, 'primary');
    });
  });
}
