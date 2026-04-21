import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_riverpod/rune_riverpod.dart';

void main() {
  group('RiverpodBridge', () {
    test('registerInto registers ProviderScope and RiverpodConsumer', () {
      final config = RuneConfig()..withBridges(const [RiverpodBridge()]);
      expect(config.widgets.find('ProviderScope'), isNotNull);
      expect(config.widgets.find('RiverpodConsumer'), isNotNull);
    });

    test('bridge is const-constructible and stateless', () {
      const a = RiverpodBridge();
      const b = RiverpodBridge();
      expect(identical(a, b), isTrue);
    });

    test('stacks on top of RuneConfig.defaults without collisions', () {
      final config = RuneConfig.defaults()
          .withBridges(const [RiverpodBridge()]);
      expect(config.widgets.find('Text'), isNotNull);
      expect(config.widgets.find('ProviderScope'), isNotNull);
    });
  });
}
