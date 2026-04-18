import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/config.dart';

void main() {
  group('RuneConfig.defaults()', () {
    test('registers Phase 1 widget builders', () {
      final c = RuneConfig.defaults();
      for (final name in const [
        'Text',
        'SizedBox',
        'Container',
        'Column',
        'Row',
      ]) {
        expect(c.widgets.contains(name), isTrue, reason: 'missing $name');
      }
    });

    test('registers EdgeInsets.all value builder', () {
      final c = RuneConfig.defaults();
      expect(c.values.contains('EdgeInsets.all'), isTrue);
    });

    test('empty config has empty registries', () {
      final c = RuneConfig();
      expect(c.widgets.size, 0);
      expect(c.values.size, 0);
    });
  });
}
