import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/bridges/rune_bridge.dart';
import 'package:rune/src/config.dart';
import 'package:rune/src/registry/extension_registry.dart';

final class _TestBridge implements RuneBridge {
  const _TestBridge();
  @override
  void registerInto(RuneConfig config) {
    config.extensions.register('testBridgeProp', (t, c) => 'registered');
  }
}

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

    test('registers Phase 2c widget builders', () {
      final c = RuneConfig.defaults();
      for (final name in const [
        'Padding',
        'Center',
        'Stack',
        'Expanded',
        'Flexible',
        'Card',
        'Icon',
        'ListView',
        'AppBar',
        'Scaffold',
      ]) {
        expect(c.widgets.contains(name), isTrue, reason: 'missing $name');
      }
    });

    test('registers Phase 2c Image value builders', () {
      final c = RuneConfig.defaults();
      expect(c.values.contains('Image.network'), isTrue);
      expect(c.values.contains('Image.asset'), isTrue);
    });

    test('seeds Phase 2c Icons.home', () {
      final c = RuneConfig.defaults();
      expect(c.constants.contains('Icons', 'home'), isTrue);
    });

    test('registers Phase 2d button builders', () {
      final c = RuneConfig.defaults();
      expect(c.widgets.contains('ElevatedButton'), isTrue);
      expect(c.widgets.contains('TextButton'), isTrue);
      expect(c.widgets.contains('IconButton'), isTrue);
    });

    test('exposes an extensions registry', () {
      final c = RuneConfig.defaults();
      expect(c.extensions, isA<ExtensionRegistry>());
    });

    test('empty config has empty extensions', () {
      final c = RuneConfig();
      expect(c.extensions.size, 0);
    });

    test('withBridges applies each bridge', () {
      final c = RuneConfig.defaults().withBridges(const [_TestBridge()]);
      expect(c.extensions.contains('testBridgeProp'), isTrue);
    });

    test('withBridges returns same config instance (fluent)', () {
      final c = RuneConfig();
      final result = c.withBridges(const [_TestBridge()]);
      expect(identical(c, result), isTrue);
    });
  });
}
