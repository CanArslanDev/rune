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

    test('exposes a constants registry', () {
      final c = RuneConfig.defaults();
      expect(c.constants, isNotNull);
    });

    test('seeds Colors.red in defaults', () {
      final c = RuneConfig.defaults();
      expect(c.constants.contains('Colors', 'red'), isTrue);
    });

    test('seeds MainAxisAlignment.center', () {
      final c = RuneConfig.defaults();
      expect(c.constants.contains('MainAxisAlignment', 'center'), isTrue);
    });

    test('empty config has empty constants registry', () {
      final c = RuneConfig();
      expect(c.constants.size, 0);
    });

    test('registers Phase 2b value builders', () {
      final c = RuneConfig.defaults();
      expect(c.values.contains('EdgeInsets.symmetric'), isTrue);
      expect(c.values.contains('EdgeInsets.only'), isTrue);
      expect(c.values.contains('EdgeInsets.fromLTRB'), isTrue);
      expect(c.values.contains('Color'), isTrue);
      expect(c.values.contains('TextStyle'), isTrue);
      expect(c.values.contains('BorderRadius.circular'), isTrue);
      expect(c.values.contains('BoxDecoration'), isTrue);
    });
  });
}
