import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_bloc/rune_bloc.dart';

void main() {
  group('BlocBridge', () {
    test('registerInto registers the three widget builders', () {
      final config = RuneConfig()..withBridges(const [BlocBridge()]);
      const names = ['BlocProvider', 'BlocBuilder', 'BlocListener'];
      for (final name in names) {
        expect(
          config.widgets.find(name),
          isNotNull,
          reason: 'widget "$name" should be registered',
        );
      }
    });

    test('bridge is const-constructible and stateless', () {
      const a = BlocBridge();
      const b = BlocBridge();
      expect(identical(a, b), isTrue);
    });

    test('stacks on top of RuneConfig.defaults without collisions', () {
      final config = RuneConfig.defaults()
          .withBridges(const [BlocBridge()]);
      expect(config.widgets.find('Text'), isNotNull);
      expect(config.widgets.find('BlocProvider'), isNotNull);
    });
  });
}
