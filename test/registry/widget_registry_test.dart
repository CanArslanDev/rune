import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/registry/widget_registry.dart';

final class _FakeBuilder implements RuneWidgetBuilder {
  const _FakeBuilder(this.typeName);
  @override
  final String typeName;
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) =>
      const SizedBox.shrink();
}

void main() {
  group('WidgetRegistry', () {
    test('registerBuilder uses builder.typeName as key', () {
      final r = WidgetRegistry();
      const b = _FakeBuilder('Foo');
      r.registerBuilder(b);
      expect(r.find('Foo'), same(b));
    });

    test('registerBuilder throws on duplicate type name', () {
      final r = WidgetRegistry();
      r.registerBuilder(const _FakeBuilder('Foo'));
      expect(
        () => r.registerBuilder(const _FakeBuilder('Foo')),
        throwsStateError,
      );
    });
  });
}
