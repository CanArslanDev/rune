import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';

void main() {
  group('RuneDataContext', () {
    test('empty has no keys', () {
      expect(RuneDataContext.empty.has('anything'), isFalse);
      expect(RuneDataContext.empty.get('anything'), isNull);
    });

    test('get returns value for known key', () {
      final ctx = RuneDataContext(const {'name': 'Ali', 'age': 30});
      expect(ctx.get('name'), 'Ali');
      expect(ctx.get('age'), 30);
    });

    test('get returns null for unknown key', () {
      final ctx = RuneDataContext(const {'x': 1});
      expect(ctx.get('y'), isNull);
    });

    test('has reflects presence even when value is null', () {
      final ctx = RuneDataContext(const {'x': null});
      expect(ctx.has('x'), isTrue);
      expect(ctx.has('y'), isFalse);
    });

    test('extend produces a new RuneDataContext with merged keys', () {
      final a = RuneDataContext(const {'x': 1, 'y': 2});
      final b = a.extend({'y': 20, 'z': 3});
      expect(b.get('x'), 1);
      expect(b.get('y'), 20);
      expect(b.get('z'), 3);
      expect(a.get('y'), 2);
      expect(a.has('z'), isFalse);
    });

    test('constructor defends against caller mutation of source map', () {
      final source = <String, Object?>{'x': 1};
      final ctx = RuneDataContext(source);
      source['x'] = 999;
      source['y'] = 'leaked';
      expect(ctx.get('x'), 1);
      expect(ctx.has('y'), isFalse);
    });

    test(
        'extend with empty additions returns a distinct but equivalent context',
        () {
      final a = RuneDataContext(const {'x': 1});
      final b = a.extend({});
      expect(identical(a, b), isFalse);
      expect(b.get('x'), 1);
    });

    test('chained extend composes correctly', () {
      final a = RuneDataContext(const {'x': 1});
      final b = a.extend({'y': 2});
      final c = b.extend({'z': 3});
      expect(c.get('x'), 1);
      expect(c.get('y'), 2);
      expect(c.get('z'), 3);
      // Original untouched.
      expect(a.has('y'), isFalse);
    });
  });
}
