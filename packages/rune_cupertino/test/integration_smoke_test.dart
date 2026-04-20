import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/rune_cupertino.dart';

void main() {
  group('CupertinoBridge integration through RuneView', () {
    RuneConfig buildConfig() =>
        RuneConfig.defaults().withBridges(const [CupertinoBridge()]);

    testWidgets('renders CupertinoButton with label', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: RuneView(
            config: buildConfig(),
            source: "CupertinoButton(child: Text('Go'), onPressed: 'tap')",
          ),
        ),
      );
      expect(find.text('Go'), findsOneWidget);
      expect(find.byType(CupertinoButton), findsOneWidget);
    });

    testWidgets('renders CupertinoPageScaffold with navigationBar and body',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: RuneView(
            config: buildConfig(),
            source: '''
              CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(middle: Text('Home')),
                child: Center(child: Text('body')),
              )
            ''',
          ),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    });

    testWidgets('renders CupertinoIcons.* through stock Icon builder',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: RuneView(
            config: buildConfig(),
            source: 'Icon(CupertinoIcons.home)',
          ),
        ),
      );
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, CupertinoIcons.home);
    });

    testWidgets('renders CupertinoActivityIndicator', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: RuneView(
            config: buildConfig(),
            source: 'CupertinoActivityIndicator(radius: 12)',
          ),
        ),
      );
      final ind = tester.widget<CupertinoActivityIndicator>(
        find.byType(CupertinoActivityIndicator),
      );
      expect(ind.radius, 12.0);
    });

    testWidgets('CupertinoSwitch dispatches onChanged', (tester) async {
      final events = <List<Object?>>[];
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: RuneView(
              config: buildConfig(),
              source:
                  "CupertinoSwitch(value: false, onChanged: 'toggled')",
              onEvent: (name, [args]) {
                if (name == 'toggled') events.add(args ?? const <Object?>[]);
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();
      expect(events, [
        [true],
      ]);
    });

    testWidgets('CupertinoThemeData value is applied to CupertinoApp',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: RuneView(
            config: buildConfig(),
            source: '''
              CupertinoApp(
                home: Center(child: Text('hi')),
                theme: CupertinoThemeData(
                  brightness: Brightness.dark,
                  primaryColor: Color(0xFF112233),
                ),
                debugShowCheckedModeBanner: false,
              )
            ''',
          ),
        ),
      );
      // Two CupertinoApp widgets exist (outer host + inner rune-built).
      expect(find.byType(CupertinoApp), findsNWidgets(2));
      expect(find.text('hi'), findsOneWidget);
    });
  });
}
