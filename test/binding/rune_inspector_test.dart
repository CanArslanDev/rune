import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_inspector.dart';

List<Map<String, Object?>> _viewsOf(Map<String, Object?> payload) {
  final raw = payload['views'];
  return (raw! as List<Object?>).cast<Map<String, Object?>>();
}

void main() {
  group('RuneInspector', () {
    setUp(RuneInspector.instance.resetForTesting);

    test('starts empty', () {
      expect(RuneInspector.instance.liveViewCount, 0);
    });

    test('registerView adds a snapshot callback; unregisterView removes it',
        () {
      final handle = RuneInspector.instance.registerView(
        () => <String, Object?>{'source': 'Text("hi")'},
      );
      expect(RuneInspector.instance.liveViewCount, 1);

      RuneInspector.instance.unregisterView(handle);
      expect(RuneInspector.instance.liveViewCount, 0);
    });

    test(
      'collectInspectionPayload returns a map with "views" keyed by id',
      () {
        final a = RuneInspector.instance.registerView(
          () => <String, Object?>{'source': 'A'},
        );
        final b = RuneInspector.instance.registerView(
          () => <String, Object?>{'source': 'B'},
        );

        final payload = RuneInspector.instance.collectInspectionPayload();
        expect(payload, containsPair('views', isA<List<Object?>>()));
        final views = _viewsOf(payload);
        expect(views.length, 2);
        final byId = {for (final v in views) v['id']: v};
        expect(byId.keys, containsAll([a.id, b.id]));
        expect(byId[a.id]!['source'], 'A');
        expect(byId[b.id]!['source'], 'B');
      },
    );

    test(
      'collectInspectionPayload freshly invokes snapshot callbacks each call',
      () {
        var counter = 0;
        RuneInspector.instance.registerView(
          () => <String, Object?>{'counter': ++counter},
        );

        final first =
            _viewsOf(RuneInspector.instance.collectInspectionPayload());
        final second =
            _viewsOf(RuneInspector.instance.collectInspectionPayload());
        expect(first.first['counter'], 1);
        expect(second.first['counter'], 2);
      },
    );

    test(
      'collectInspectionPayload captures errors thrown by a snapshot builder',
      () {
        RuneInspector.instance.registerView(
          () => throw StateError('snapshot blew up'),
        );
        final payload = RuneInspector.instance.collectInspectionPayload();
        final only = _viewsOf(payload).first;
        expect(only['snapshotError'], isA<String>());
        expect(
          only['snapshotError'].toString(),
          contains('snapshot blew up'),
        );
      },
    );

    test('payload encodes cleanly as JSON', () {
      RuneInspector.instance.registerView(
        () => <String, Object?>{
          'source': "Text('hi')",
          'data': <String, Object?>{
            'a': 1,
            'b': ['x', 'y'],
          },
          'lastError': null,
        },
      );
      final payload = RuneInspector.instance.collectInspectionPayload();
      // Must round-trip through JSON.
      expect(() => jsonEncode(payload), returnsNormally);
    });

    test(
      'serialiseForWire coerces non-JSON-native leaves to strings',
      () {
        RuneInspector.instance.registerView(
          () => <String, Object?>{
            // Regex is not JSON-native; should stringify.
            'pattern': RegExp(r'\d+'),
            // DateTime is not JSON-native; should stringify.
            'ts': DateTime(2026, 4, 20, 12),
          },
        );
        final payload = RuneInspector.instance.collectInspectionPayload();
        final view = _viewsOf(payload).first;
        expect(view['pattern'], isA<String>());
        expect(view['ts'], isA<String>());
        // Still JSON-encodable.
        expect(() => jsonEncode(payload), returnsNormally);
      },
    );

    test(
      'unregisterView tolerates a handle that was already removed',
      () {
        final handle = RuneInspector.instance.registerView(
          () => <String, Object?>{'source': ''},
        );
        RuneInspector.instance.unregisterView(handle);
        // Second call is a no-op and must not throw.
        expect(
          () => RuneInspector.instance.unregisterView(handle),
          returnsNormally,
        );
      },
    );
  });
}
