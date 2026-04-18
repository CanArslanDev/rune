// test/integration/phase_2a_smoke_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('Phase 2a integration', () {
    testWidgets('Column honors mainAxisAlignment constant', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('a'), Text('b')],
          )
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('Row honors crossAxisAlignment + mainAxisSize', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: '''
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [Text('L'), Text('R')],
          )
        ''',
        config: RuneConfig.defaults(),
      ),),);
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(row.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('data-bound Text renders from RuneDataContext',
        (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: 'Text(greeting)',
        config: RuneConfig.defaults(),
        data: const {'greeting': 'Hello from data'},
      ),),);
      expect(find.text('Hello from data'), findsOneWidget);
    });

    testWidgets('StringInterpolation with data identifier renders',
        (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: r"Text('Hello $name!')",
        config: RuneConfig.defaults(),
        data: const {'name': 'Ali'},
      ),),);
      expect(find.text('Hello Ali!'), findsOneWidget);
    });

    testWidgets('Container applies EdgeInsets.zero from constants',
        (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: "Container(padding: EdgeInsets.zero, child: Text('x'))",
        config: RuneConfig.defaults(),
      ),),);
      final c = tester.widget<Container>(find.byType(Container));
      expect(c.padding, EdgeInsets.zero);
    });

    testWidgets('unknown data key fallbacks via onError', (tester) async {
      Object? captured;
      await tester.pumpWidget(_wrap(RuneView(
        source: 'Text(missingKey)',
        config: RuneConfig.defaults(),
        fallback: const Text('FALLBACK'),
        onError: (e, _) => captured = e,
      ),),);
      expect(find.text('FALLBACK'), findsOneWidget);
      expect(captured, isA<BindingException>());
    });
  });
}
