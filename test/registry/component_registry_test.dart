import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/rune_component.dart';
import 'package:rune/src/registry/component_registry.dart';

RuneComponent _mk(String name, [List<String> params = const []]) {
  return RuneComponent(
    name: name,
    parameterNames: params,
    body: (args) => args,
  );
}

void main() {
  group('ComponentRegistry', () {
    test('empty registry: find returns null, size is 0, contains is false', () {
      final r = ComponentRegistry();
      expect(r.find('X'), isNull);
      expect(r.size, 0);
      expect(r.contains('X'), isFalse);
    });

    test('register then find returns the component', () {
      final r = ComponentRegistry();
      final c = _mk('Foo', const ['a']);
      r.register(c);
      expect(r.find('Foo'), same(c));
      expect(r.contains('Foo'), isTrue);
    });

    test('registering a duplicate name throws StateError', () {
      final r = ComponentRegistry()..register(_mk('Dup'));
      expect(() => r.register(_mk('Dup')), throwsStateError);
    });

    test('contains returns true for registered, false for absent', () {
      final r = ComponentRegistry()..register(_mk('Here'));
      expect(r.contains('Here'), isTrue);
      expect(r.contains('Missing'), isFalse);
    });

    test('size grows with each registration', () {
      final r = ComponentRegistry();
      expect(r.size, 0);
      r.register(_mk('A'));
      expect(r.size, 1);
      r.register(_mk('B'));
      expect(r.size, 2);
    });

    test('different registries are independent', () {
      final r1 = ComponentRegistry()..register(_mk('OnlyInOne'));
      final r2 = ComponentRegistry();
      expect(r1.contains('OnlyInOne'), isTrue);
      expect(r2.contains('OnlyInOne'), isFalse);
    });
  });
}
