import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/rune_component.dart';

void main() {
  group('RuneComponent', () {
    test('stores name, parameterNames, and body', () {
      Object? capturedArgs;
      final component = RuneComponent(
        name: 'MyButton',
        parameterNames: const ['label', 'onTap'],
        body: (args) {
          capturedArgs = args;
          return 'built';
        },
      );
      expect(component.name, 'MyButton');
      expect(component.parameterNames, ['label', 'onTap']);
      final result = component.body(['Click', 'evt']);
      expect(result, 'built');
      expect(capturedArgs, ['Click', 'evt']);
    });

    test('supports components with zero parameters', () {
      final component = RuneComponent(
        name: 'Logo',
        parameterNames: const <String>[],
        body: (args) => 'logo:${args.length}',
      );
      expect(component.parameterNames, isEmpty);
      expect(component.body(const <Object?>[]), 'logo:0');
    });

    test('body can return any Object? value', () {
      final listComponent = RuneComponent(
        name: 'Pair',
        parameterNames: const ['a', 'b'],
        body: (args) => <Object?>[args[0], args[1]],
      );
      final result = listComponent.body([1, 2]);
      expect(result, [1, 2]);
    });

    test('toString includes the component name', () {
      final component = RuneComponent(
        name: 'Greeting',
        parameterNames: const ['who'],
        body: (_) => 0,
      );
      expect(component.toString(), contains('Greeting'));
    });

    test('different instances are not equal by default (identity)', () {
      final a = RuneComponent(
        name: 'X',
        parameterNames: const <String>[],
        body: (_) => 0,
      );
      final b = RuneComponent(
        name: 'X',
        parameterNames: const <String>[],
        body: (_) => 0,
      );
      expect(identical(a, b), isFalse);
    });

    test('parameterNames list is honoured in declared order', () {
      final component = RuneComponent(
        name: 'Three',
        parameterNames: const ['alpha', 'beta', 'gamma'],
        body: (args) => '${args[0]}-${args[1]}-${args[2]}',
      );
      expect(component.body(['a', 'b', 'c']), 'a-b-c');
    });
  });
}
