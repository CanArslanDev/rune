import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/defaults/rune_defaults.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

void main() {
  group('RuneDefaults', () {
    test('registerWidgets seeds the full Phase 1-2d widget set', () {
      final r = WidgetRegistry();
      RuneDefaults.registerWidgets(r);
      for (final name in const [
        'Text',
        'SizedBox',
        'Container',
        'Column',
        'Row',
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
        'ElevatedButton',
        'TextButton',
        'IconButton',
        'TextField',
        'Switch',
        'Checkbox',
        'Slider',
        'Radio',
        'ListTile',
        'Divider',
        'Spacer',
        'GestureDetector',
        'InkWell',
        'SingleChildScrollView',
        'Wrap',
        'AspectRatio',
        'Positioned',
        'AnimatedContainer',
        'AnimatedOpacity',
        'AnimatedPositioned',
        'BottomNavigationBar',
        'TabBar',
        'Tab',
      ]) {
        expect(r.contains(name), isTrue, reason: 'missing widget $name');
      }
    });

    test('registerValues seeds the full Phase 1-2c value set', () {
      final r = ValueRegistry();
      RuneDefaults.registerValues(r);
      for (final key in const [
        'EdgeInsets.all',
        'EdgeInsets.symmetric',
        'EdgeInsets.only',
        'EdgeInsets.fromLTRB',
        'Color',
        'TextStyle',
        'BorderRadius.circular',
        'BoxDecoration',
        'Image.network',
        'Image.asset',
        'Duration',
        'BottomNavigationBarItem',
      ]) {
        expect(r.contains(key), isTrue, reason: 'missing value $key');
      }
    });

    test('registerConstants seeds Phase 2a + Phase 2c icons', () {
      final r = ConstantRegistry();
      RuneDefaults.registerConstants(r);
      expect(r.contains('Colors', 'red'), isTrue);
      expect(r.contains('MainAxisAlignment', 'center'), isTrue);
      expect(r.contains('FlexFit', 'tight'), isTrue);
      expect(r.contains('BoxShape', 'circle'), isTrue);
      expect(r.contains('Icons', 'home'), isTrue);
    });

    test('individual register* calls combined produce the full set', () {
      final w = WidgetRegistry();
      final v = ValueRegistry();
      final c = ConstantRegistry();
      RuneDefaults.registerWidgets(w);
      RuneDefaults.registerValues(v);
      RuneDefaults.registerConstants(c);
      expect(w.size, greaterThanOrEqualTo(38));
      expect(v.size, greaterThanOrEqualTo(12));
      expect(c.size, greaterThanOrEqualTo(50));
    });
  });
}
