import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/bridges/rune_bridge.dart';
import 'package:rune/src/config.dart';

final class _FakeBridge implements RuneBridge {
  _FakeBridge();
  bool registered = false;
  @override
  void registerInto(RuneConfig config) {
    registered = true;
  }
}

void main() {
  group('RuneBridge', () {
    test('registerInto is invoked with the config', () {
      final bridge = _FakeBridge();
      final config = RuneConfig();
      bridge.registerInto(config);
      expect(bridge.registered, isTrue);
    });

    test('multiple bridges each see the same config instance', () {
      final a = _FakeBridge();
      final b = _FakeBridge();
      final config = RuneConfig();
      a.registerInto(config);
      b.registerInto(config);
      expect(a.registered, isTrue);
      expect(b.registered, isTrue);
    });
  });
}
