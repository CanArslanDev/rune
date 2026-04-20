import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

List<Map<String, Object?>> _views(Map<String, Object?> payload) =>
    (payload['views']! as List<Object?>).cast<Map<String, Object?>>();

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('RuneInspector <-> RuneView wiring', () {
    setUp(RuneInspector.instance.resetForTesting);
    tearDown(RuneInspector.instance.resetForTesting);

    testWidgets('mounting a RuneView registers it with the inspector',
        (tester) async {
      expect(RuneInspector.instance.liveViewCount, 0);

      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: "Text('hello')",
            config: RuneConfig.defaults(),
          ),
        ),
      );

      expect(RuneInspector.instance.liveViewCount, 1);

      final payload = RuneInspector.instance.collectInspectionPayload();
      final views = _views(payload);
      expect(views, hasLength(1));
      expect(views.first['source'], "Text('hello')");
      expect(views.first['data'], isA<Map<String, Object?>>());
      expect(views.first['lastError'], isNull);
    });

    testWidgets('unmounting a RuneView deregisters it from the inspector',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: "Text('a')",
            config: RuneConfig.defaults(),
          ),
        ),
      );
      expect(RuneInspector.instance.liveViewCount, 1);

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      expect(RuneInspector.instance.liveViewCount, 0);
    });

    testWidgets(
      'two mounted views produce two distinct payload entries',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                RuneView(
                  source: "Text('first')",
                  config: RuneConfig.defaults(),
                ),
                RuneView(
                  source: "Text('second')",
                  config: RuneConfig.defaults(),
                  data: const {'k': 'v'},
                ),
              ],
            ),
          ),
        );

        expect(RuneInspector.instance.liveViewCount, 2);
        final views = _views(
          RuneInspector.instance.collectInspectionPayload(),
        );
        final sources = views.map((v) => v['source']).toSet();
        expect(sources, {"Text('first')", "Text('second')"});
      },
    );

    testWidgets(
      'lastError is populated after a render throws',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              // UnregisteredBuilderException: "NoSuchWidget" is not a
              // default.
              source: 'NoSuchWidget()',
              config: RuneConfig.defaults(),
            ),
          ),
        );

        final views = _views(
          RuneInspector.instance.collectInspectionPayload(),
        );
        expect(views.first['lastError'], isA<String>());
        expect(
          views.first['lastError'].toString(),
          contains('NoSuchWidget'),
        );
      },
    );

    testWidgets('payload is JSON-encodable end-to-end', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: "Text('hi')",
            config: RuneConfig.defaults(),
            data: const {
              'count': 7,
              'nested': {'flag': true},
            },
          ),
        ),
      );

      final payload = RuneInspector.instance.collectInspectionPayload();
      expect(() => jsonEncode(payload), returnsNormally);
    });
  });
}
