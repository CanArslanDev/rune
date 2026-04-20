import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_router/rune_router.dart';

void main() {
  group('RouterBridge', () {
    test('registerInto registers the GoRoute and GoRouter values', () {
      final config = RuneConfig()..withBridges(const [RouterBridge()]);
      expect(config.values.findValue('GoRoute'), isNotNull);
      expect(config.values.findValue('GoRouter'), isNotNull);
    });

    test('registerInto registers the GoRouterApp widget', () {
      final config = RuneConfig()..withBridges(const [RouterBridge()]);
      expect(config.widgets.find('GoRouterApp'), isNotNull);
    });

    test('bridge is const-constructible and stateless', () {
      const a = RouterBridge();
      const b = RouterBridge();
      expect(identical(a, b), isTrue);
    });

    test('stacks on top of RuneConfig.defaults without collisions', () {
      final config = RuneConfig.defaults()
          .withBridges(const [RouterBridge()]);
      expect(config.widgets.find('Text'), isNotNull);
      expect(config.widgets.find('GoRouterApp'), isNotNull);
      expect(config.values.findValue('GoRoute'), isNotNull);
      expect(config.values.findValue('GoRouter'), isNotNull);
    });
  });
}
