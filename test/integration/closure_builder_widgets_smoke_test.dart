import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('v1.2.0 smoke: closure-based builder widgets via RuneView', () {
    testWidgets(
      'ListView.builder lazily materialises items from a closure',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SizedBox(
              height: 400,
              child: RuneView(
                source: r'''
                  ListView.builder(
                    itemCount: 50,
                    itemBuilder: (ctx, index) => Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Item ${index}'),
                    ),
                  )
                ''',
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        );
        // Items at the top of the list are built eagerly.
        expect(find.text('Item 0'), findsOneWidget);
        expect(find.text('Item 1'), findsOneWidget);
        // Items further down are not mounted until scrolled into view.
        expect(find.text('Item 49'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'GridView.countBuilder produces a lazy grid of computed tiles',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SizedBox(
              width: 400,
              height: 400,
              child: RuneView(
                source: r'''
                  GridView.countBuilder(
                    crossAxisCount: 2,
                    itemCount: 6,
                    itemBuilder: (ctx, i) => Center(
                      child: Text('Tile ${i}'),
                    ),
                  )
                ''',
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        );
        expect(find.text('Tile 0'), findsOneWidget);
        expect(find.text('Tile 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'FutureBuilder resolves a host-provided Future and rebuilds',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: r'''
                FutureBuilder(
                  future: myFuture,
                  builder: (ctx, snapshot) => snapshot.hasData
                    ? Text('Result: ${snapshot.data}')
                    : Text('Loading'),
                )
              ''',
              config: RuneConfig.defaults(),
              data: <String, Object?>{
                'myFuture': Future<Object?>.value('hello'),
              },
            ),
          ),
        );
        // Before the future completes the loading branch renders.
        expect(find.text('Loading'), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.text('Result: hello'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'LayoutBuilder picks the branch based on constraints.maxWidth',
      (tester) async {
        const source = '''
          LayoutBuilder(
            builder: (ctx, constraints) => constraints.maxWidth > 300
              ? Text('wide')
              : Text('narrow'),
          )
        ''';

        await tester.pumpWidget(
          _wrap(
            SizedBox(
              width: 400,
              child: RuneView(
                source: source,
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        );
        expect(find.text('wide'), findsOneWidget);
        expect(find.text('narrow'), findsNothing);

        await tester.pumpWidget(
          _wrap(
            SizedBox(
              width: 200,
              child: RuneView(
                source: source,
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        );
        expect(find.text('narrow'), findsOneWidget);
        expect(find.text('wide'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'SliverList.builder works inside a CustomScrollView',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SizedBox(
              height: 400,
              child: RuneView(
                source: r'''
                  CustomScrollView(
                    slivers: [
                      SliverList.builder(
                        itemCount: 20,
                        itemBuilder: (ctx, i) => Text('row ${i}'),
                      ),
                    ],
                  )
                ''',
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        );
        expect(find.text('row 0'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
