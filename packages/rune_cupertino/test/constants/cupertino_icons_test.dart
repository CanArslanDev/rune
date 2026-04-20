import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/constants/cupertino_icons.dart';

void main() {
  group('registerCupertinoIcons', () {
    test('seeds the CupertinoIcons type bucket', () {
      final r = ConstantRegistry();
      registerCupertinoIcons(r);
      expect(r.contains('CupertinoIcons', 'home'), isTrue);
      expect(r.contains('CupertinoIcons', 'settings'), isTrue);
      expect(r.contains('CupertinoIcons', 'heart'), isTrue);
      expect(r.contains('CupertinoIcons', 'xmark'), isTrue);
    });

    test('resolved entries are IconData instances', () {
      final r = ConstantRegistry();
      registerCupertinoIcons(r);
      final home = r.resolve('CupertinoIcons', 'home');
      expect(home, isA<IconData>());
      expect(home, CupertinoIcons.home);
    });

    test('registers at least 30 entries', () {
      final r = ConstantRegistry();
      registerCupertinoIcons(r);
      final names = r.memberNamesOf('CupertinoIcons').toList();
      expect(names.length, greaterThanOrEqualTo(30));
    });

    test('throws on duplicate registration', () {
      final r = ConstantRegistry();
      registerCupertinoIcons(r);
      expect(
        () => registerCupertinoIcons(r),
        throwsA(isA<StateError>()),
      );
    });
  });
}
