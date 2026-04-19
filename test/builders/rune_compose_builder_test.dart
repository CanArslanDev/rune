import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/rune_compose_builder.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_component.dart';

import '../_helpers/test_context.dart';

RuneComponent _noop(String name) => RuneComponent(
      name: name,
      parameterNames: const <String>[],
      body: (_) => const SizedBox.shrink(),
    );

void main() {
  group('RuneComposeBuilder', () {
    test('typeName == "RuneCompose"', () {
      expect(const RuneComposeBuilder().typeName, 'RuneCompose');
    });

    test('returns the root widget when components + root are supplied', () {
      const b = RuneComposeBuilder();
      const rootWidget = Text('hi', textDirection: TextDirection.ltr);
      final args = ResolvedArguments(
        named: <String, Object?>{
          'components': <Object?>[_noop('A'), _noop('B')],
          'root': rootWidget,
        },
      );
      final out = b.build(args, testContext());
      expect(out, same(rootWidget));
    });

    test('missing `components` raises ArgumentException', () {
      const b = RuneComposeBuilder();
      expect(
        () => b.build(
          const ResolvedArguments(
            named: <String, Object?>{
              'root': SizedBox.shrink(),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing `root` raises ArgumentException', () {
      const b = RuneComposeBuilder();
      final args = ResolvedArguments(
        named: <String, Object?>{
          'components': <Object?>[_noop('A')],
        },
      );
      expect(
        () => b.build(args, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-RuneComponent entry in `components` raises ArgumentException',
        () {
      const b = RuneComposeBuilder();
      final args = ResolvedArguments(
        named: <String, Object?>{
          'components': <Object?>[_noop('A'), 42],
          'root': const SizedBox.shrink(),
        },
      );
      expect(
        () => b.build(args, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}
