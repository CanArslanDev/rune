import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/rune_cupertino.dart';

void main() {
  group('CupertinoBridge', () {
    test('registerInto registers all fifteen widget builders', () {
      final config = RuneConfig()..withBridges(const [CupertinoBridge()]);
      const expectedWidgets = <String>{
        'CupertinoApp',
        'CupertinoPageScaffold',
        'CupertinoNavigationBar',
        'CupertinoButton',
        'CupertinoSwitch',
        'CupertinoSlider',
        'CupertinoTextField',
        'CupertinoActivityIndicator',
        'CupertinoAlertDialog',
        'CupertinoDialogAction',
        'CupertinoPicker',
        'CupertinoActionSheet',
        'CupertinoSegmentedControl',
        'CupertinoTabBar',
        'CupertinoTabScaffold',
      };
      for (final name in expectedWidgets) {
        expect(
          config.widgets.find(name),
          isNotNull,
          reason: 'widget "$name" should be registered',
        );
      }
    });

    test('registerInto registers the three value builders', () {
      final config = RuneConfig()..withBridges(const [CupertinoBridge()]);
      expect(config.values.findValue('CupertinoThemeData'), isNotNull);
      expect(
        config.values.findValue('CupertinoActionSheetAction'),
        isNotNull,
      );
      expect(
        config.values.findValue('FixedExtentScrollController'),
        isNotNull,
      );
    });

    test('registerInto seeds CupertinoIcons constants', () {
      final config = RuneConfig()..withBridges(const [CupertinoBridge()]);
      expect(config.constants.contains('CupertinoIcons', 'home'), isTrue);
      expect(
        config.constants.contains('CupertinoIcons', 'left_chevron'),
        isTrue,
      );
      expect(config.constants.contains('CupertinoIcons', 'settings'), isTrue);
      expect(config.constants.contains('CupertinoIcons', 'heart'), isTrue);
    });

    test('registers at least 30 CupertinoIcons entries', () {
      final config = RuneConfig()..withBridges(const [CupertinoBridge()]);
      final count = config.constants.memberNamesOf('CupertinoIcons').length;
      expect(count, greaterThanOrEqualTo(30));
    });

    test('bridge is const-constructible and stateless', () {
      const a = CupertinoBridge();
      const b = CupertinoBridge();
      expect(identical(a, b), isTrue);
    });

    test('stacks on top of RuneConfig.defaults without collisions', () {
      final config = RuneConfig.defaults()
          .withBridges(const [CupertinoBridge()]);
      // Material defaults stay present.
      expect(config.widgets.find('Text'), isNotNull);
      // Cupertino additions are also present.
      expect(config.widgets.find('CupertinoButton'), isNotNull);
    });
  });
}
