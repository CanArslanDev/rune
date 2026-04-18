import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/defaults/phase_2c_icons.dart';
import 'package:rune/src/registry/constant_registry.dart';

void main() {
  group('registerPhase2cIcons', () {
    test('seeds common icons', () {
      final r = ConstantRegistry();
      registerPhase2cIcons(r);
      expect(r.resolve('Icons', 'home'), Icons.home);
      expect(r.resolve('Icons', 'menu'), Icons.menu);
      expect(r.resolve('Icons', 'close'), Icons.close);
      expect(r.resolve('Icons', 'search'), Icons.search);
      expect(r.resolve('Icons', 'settings'), Icons.settings);
      expect(r.resolve('Icons', 'favorite'), Icons.favorite);
      expect(r.resolve('Icons', 'star'), Icons.star);
      expect(r.resolve('Icons', 'add'), Icons.add);
      expect(r.resolve('Icons', 'delete'), Icons.delete);
      expect(r.resolve('Icons', 'edit'), Icons.edit);
    });

    test('seeds at least 50 icons', () {
      final r = ConstantRegistry();
      registerPhase2cIcons(r);
      expect(r.size, greaterThanOrEqualTo(50));
    });

    test('double registration throws StateError', () {
      final r = ConstantRegistry();
      registerPhase2cIcons(r);
      expect(() => registerPhase2cIcons(r), throwsStateError);
    });
  });
}
