import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/registry/value_registry.dart';

final class _FakeValue implements RuneValueBuilder {
  const _FakeValue(this.typeName, this.constructorName, this._value);
  @override
  final String typeName;
  @override
  final String? constructorName;
  final Object _value;
  @override
  Object build(ResolvedArguments args, RuneContext ctx) => _value;
}

void main() {
  group('ValueRegistry', () {
    test('default constructor keyed by type name only', () {
      final r = ValueRegistry();
      const b = _FakeValue('TextStyle', null, 'ok');
      r.registerBuilder(b);
      expect(r.find('TextStyle'), same(b));
      expect(r.findValue('TextStyle'), same(b));
    });

    test('named constructor keyed as TypeName.constructor', () {
      final r = ValueRegistry();
      const b = _FakeValue('EdgeInsets', 'all', 'ok');
      r.registerBuilder(b);
      expect(r.find('EdgeInsets.all'), same(b));
      expect(r.findValue('EdgeInsets', constructorName: 'all'), same(b));
      expect(r.findValue('EdgeInsets'), isNull);
    });

    test('coexistence of default and named constructors', () {
      final r = ValueRegistry();
      const a = _FakeValue('X', null, 1);
      const b = _FakeValue('X', 'foo', 2);
      r
        ..registerBuilder(a)
        ..registerBuilder(b);
      expect(r.findValue('X'), same(a));
      expect(r.findValue('X', constructorName: 'foo'), same(b));
    });
  });
}
