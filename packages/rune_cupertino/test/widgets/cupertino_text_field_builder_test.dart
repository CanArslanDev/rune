import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_text_field_builder.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget child) {
  return CupertinoApp(home: Center(child: child));
}

void main() {
  group('CupertinoTextFieldBuilder', () {
    const b = CupertinoTextFieldBuilder();

    test('typeName is "CupertinoTextField"', () {
      expect(b.typeName, 'CupertinoTextField');
    });

    testWidgets('renders with the provided initial value', (tester) async {
      final widget = b.build(
        const ResolvedArguments(named: {'value': 'hello'}),
        testContext(),
      );
      await tester.pumpWidget(_harness(widget));
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      expect(field.controller!.text, 'hello');
    });

    testWidgets('placeholder is forwarded', (tester) async {
      final widget = b.build(
        const ResolvedArguments(named: {'placeholder': 'Name'}),
        testContext(),
      );
      await tester.pumpWidget(_harness(widget));
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      expect(field.placeholder, 'Name');
    });

    testWidgets('onChanged dispatches the new text', (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'typed') captured.add(args);
      });
      final widget = b.build(
        const ResolvedArguments(
          named: {'value': '', 'onChanged': 'typed'},
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(widget));
      await tester.enterText(find.byType(CupertinoTextField), 'a');
      expect(captured, [
        ['a'],
      ]);
    });

    testWidgets('external controller bypasses the internal one',
        (tester) async {
      final controller = TextEditingController(text: 'ext');
      addTearDown(controller.dispose);
      final widget = b.build(
        ResolvedArguments(named: {'controller': controller}),
        testContext(),
      );
      await tester.pumpWidget(_harness(widget));
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      expect(identical(field.controller, controller), isTrue);
      expect(field.controller!.text, 'ext');
    });

    testWidgets('obscureText and enabled flags are forwarded',
        (tester) async {
      final widget = b.build(
        const ResolvedArguments(
          named: {'obscureText': true, 'enabled': false},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(widget));
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      expect(field.obscureText, isTrue);
      expect(field.enabled, isFalse);
    });
  });
}
