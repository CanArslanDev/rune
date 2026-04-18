import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/data_context.dart';

void main() {
  group('DataContext', () {
    test('empty has no keys', () {
      expect(DataContext.empty.has('anything'), isFalse);
      expect(DataContext.empty.get('anything'), isNull);
    });

    test('get returns value for known key', () {
      const ctx = DataContext({'name': 'Ali', 'age': 30});
      expect(ctx.get('name'), 'Ali');
      expect(ctx.get('age'), 30);
    });

    test('get returns null for unknown key', () {
      const ctx = DataContext({'x': 1});
      expect(ctx.get('y'), isNull);
    });

    test('has reflects presence even when value is null', () {
      const ctx = DataContext({'x': null});
      expect(ctx.has('x'), isTrue);
      expect(ctx.has('y'), isFalse);
    });

    test('extend produces a new DataContext with merged keys', () {
      const a = DataContext({'x': 1, 'y': 2});
      final b = a.extend({'y': 20, 'z': 3});
      expect(b.get('x'), 1);
      expect(b.get('y'), 20);
      expect(b.get('z'), 3);
      // Original untouched.
      expect(a.get('y'), 2);
      expect(a.has('z'), isFalse);
    });
  });
}
