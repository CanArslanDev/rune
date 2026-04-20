import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_provider/rune_provider.dart';

void main() {
  group('ProviderBridge', () {
    test('registerInto registers the three widget builders', () {
      final config = RuneConfig()..withBridges(const [ProviderBridge()]);
      const expected = <String>{
        'ChangeNotifierProvider',
        'Consumer',
        'Selector',
      };
      for (final name in expected) {
        expect(
          config.widgets.find(name),
          isNotNull,
          reason: 'widget "$name" should be registered',
        );
      }
    });

    test('bridge is const-constructible and stateless', () {
      const a = ProviderBridge();
      const b = ProviderBridge();
      expect(identical(a, b), isTrue);
    });

    test('stacks on top of RuneConfig.defaults without collisions', () {
      final config = RuneConfig.defaults()
          .withBridges(const [ProviderBridge()]);
      expect(config.widgets.find('Text'), isNotNull);
      expect(config.widgets.find('ChangeNotifierProvider'), isNotNull);
      expect(config.widgets.find('Consumer'), isNotNull);
      expect(config.widgets.find('Selector'), isNotNull);
    });
  });
}
