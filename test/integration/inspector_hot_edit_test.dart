import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

List<Map<String, Object?>> _views(Map<String, Object?> payload) =>
    (payload['views']! as List<Object?>).cast<Map<String, Object?>>();

int _firstViewId() =>
    _views(RuneInspector.instance.collectInspectionPayload())
        .first['id']! as int;

void main() {
  group('RuneInspector hot-edit (Phase 3)', () {
    setUp(RuneInspector.instance.resetForTesting);
    tearDown(RuneInspector.instance.resetForTesting);

    testWidgets(
      'setSourceOverrideById replaces the rendered source',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: "Text('original')",
              config: RuneConfig.defaults(),
            ),
          ),
        );

        expect(find.text('original'), findsOneWidget);
        expect(RuneInspector.instance.liveViewCount, 1);

        RuneInspector.instance.setSourceOverrideById(
          _firstViewId(),
          "Text('edited live')",
        );
        await tester.pump();

        expect(find.text('original'), findsNothing);
        expect(find.text('edited live'), findsOneWidget);
      },
    );

    testWidgets(
      'payload surfaces overridden and originalSource fields',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: "Text('v1')",
              config: RuneConfig.defaults(),
            ),
          ),
        );

        final before = _views(
          RuneInspector.instance.collectInspectionPayload(),
        ).first;
        expect(before['overridden'], isFalse);
        expect(before['originalSource'], isNull);
        expect(before['source'], "Text('v1')");

        final id = before['id']! as int;
        RuneInspector.instance.setSourceOverrideById(id, "Text('v2')");
        await tester.pump();

        final after = _views(
          RuneInspector.instance.collectInspectionPayload(),
        ).first;
        expect(after['overridden'], isTrue);
        expect(after['originalSource'], "Text('v1')");
        expect(after['source'], "Text('v2')");
      },
    );

    testWidgets(
      'null override reverts to the widget source',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: "Text('widget-source')",
              config: RuneConfig.defaults(),
            ),
          ),
        );

        final id = _firstViewId();
        RuneInspector.instance.setSourceOverrideById(id, "Text('override')");
        await tester.pump();
        expect(find.text('override'), findsOneWidget);

        RuneInspector.instance.setSourceOverrideById(id, null);
        await tester.pump();
        expect(find.text('widget-source'), findsOneWidget);
      },
    );

    testWidgets(
      'cache is cleared on override so the new source reparses',
      (tester) async {
        // If we did not clear the parse cache, the override would
        // still reparse because the lookup key is the new string;
        // we test the opposite case: the OLD cached AST must not
        // serve the new source if we revert then re-apply.
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: "Text('v1')",
              config: RuneConfig.defaults(),
            ),
          ),
        );
        final id = _firstViewId();

        RuneInspector.instance.setSourceOverrideById(id, "Text('v2')");
        await tester.pump();
        expect(find.text('v2'), findsOneWidget);

        RuneInspector.instance.setSourceOverrideById(id, null);
        await tester.pump();
        expect(find.text('v1'), findsOneWidget);

        RuneInspector.instance.setSourceOverrideById(id, "Text('v3')");
        await tester.pump();
        expect(find.text('v3'), findsOneWidget);
      },
    );
  });
}
