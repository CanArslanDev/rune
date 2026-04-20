// Payload parsing is the one piece of pure Dart logic in the
// extension app (the rest is DevTools UI). Testing it in isolation
// keeps the extension's wire format locked down independently of
// any DevTools framework churn.
//
// We inline the _ViewPayload model here to avoid leaking private
// symbols from lib/main.dart; the parser mirrors the shape exactly.
// If the main app's model grows new fields, this test file grows
// with it.

import 'package:flutter_test/flutter_test.dart';

class ViewPayload {
  const ViewPayload({
    required this.id,
    required this.source,
    required this.data,
    required this.cacheSize,
    required this.lastError,
    required this.snapshotError,
  });

  factory ViewPayload.fromJson(Map<String, Object?> json) {
    final idRaw = json['id'];
    return ViewPayload(
      id: idRaw is int ? idRaw : int.tryParse('$idRaw') ?? -1,
      source: (json['source'] as String?) ?? '',
      data: json['data'] is Map
          ? Map<String, Object?>.from(json['data']! as Map)
          : const <String, Object?>{},
      cacheSize: (json['cacheSize'] as num?)?.toInt(),
      lastError: json['lastError'] as String?,
      snapshotError: json['snapshotError'] as String?,
    );
  }

  final int id;
  final String source;
  final Map<String, Object?> data;
  final int? cacheSize;
  final String? lastError;
  final String? snapshotError;
}

void main() {
  group('ViewPayload.fromJson', () {
    test('parses the full happy-path payload', () {
      final payload = ViewPayload.fromJson({
        'id': 7,
        'source': "Text('hi')",
        'data': {'count': 3},
        'cacheSize': 2,
        'lastError': null,
      });
      expect(payload.id, 7);
      expect(payload.source, "Text('hi')");
      expect(payload.data, {'count': 3});
      expect(payload.cacheSize, 2);
      expect(payload.lastError, isNull);
      expect(payload.snapshotError, isNull);
    });

    test('defaults source to empty when absent', () {
      final payload = ViewPayload.fromJson({'id': 0});
      expect(payload.source, '');
      expect(payload.data, isEmpty);
      expect(payload.cacheSize, isNull);
    });

    test('coerces stringly-typed id back to int', () {
      final payload = ViewPayload.fromJson({'id': '9'});
      expect(payload.id, 9);
    });

    test('falls back to -1 on unparseable id', () {
      final payload = ViewPayload.fromJson({'id': 'not a number'});
      expect(payload.id, -1);
    });

    test('ignores non-Map data shapes', () {
      final payload = ViewPayload.fromJson({
        'id': 1,
        'data': 'a string instead of a map',
      });
      expect(payload.data, isEmpty);
    });

    test('preserves lastError and snapshotError strings when present', () {
      final payload = ViewPayload.fromJson({
        'id': 2,
        'source': '',
        'lastError': 'UnregisteredBuilderException: No builder for "X"',
        'snapshotError': 'StateError: whoops',
      });
      expect(payload.lastError, contains('UnregisteredBuilderException'));
      expect(payload.snapshotError, contains('whoops'));
    });

    test('cacheSize coerces num types to int', () {
      final payload = ViewPayload.fromJson({
        'id': 3,
        'cacheSize': 4.0,
      });
      expect(payload.cacheSize, 4);
    });
  });
}
