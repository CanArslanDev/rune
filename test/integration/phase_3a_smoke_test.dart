// test/integration/phase_3a_smoke_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// A tiny bridge used for the integration test: registers a `.px`
/// extension that converts a numeric target to a double (identity for
/// now — real sizers would use MediaQuery via ctx.flutterContext).
final class _PxBridge implements RuneBridge {
  const _PxBridge();
  @override
  void registerInto(RuneConfig config) {
    config.extensions.register('px', (target, ctx) {
      if (target is num) return target.toDouble();
      throw ArgumentError(
        'Expected num target for .px, got ${target.runtimeType}',
      );
    });
  }
}

void main() {
  group('Phase 3a integration — extensions + bridges', () {
    testWidgets('SizedBox(width: 24.px) via the PxBridge', (tester) async {
      final config = RuneConfig.defaults()
          .withBridges(const [_PxBridge()]);
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: "SizedBox(width: 24.px, child: Text('x'))",
            config: config,
          ),
        ),
      );
      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.width, 24.0);
    });

    testWidgets('parenthesized literal: (100).px', (tester) async {
      final config = RuneConfig.defaults()
          .withBridges(const [_PxBridge()]);
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: "SizedBox(width: (100).px, child: Text('x'))",
            config: config,
          ),
        ),
      );
      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.width, 100.0);
    });

    testWidgets('unknown property falls through to onError',
        (tester) async {
      Object? captured;
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: "SizedBox(width: 10.notRegistered, child: Text('x'))",
            config: RuneConfig.defaults(),
            fallback: const Text('FALLBACK'),
            onError: (e, _) => captured = e,
          ),
        ),
      );
      expect(find.text('FALLBACK'), findsOneWidget);
      expect(captured, isA<ResolveException>());
    });

    testWidgets('data-prefix: Text(user.name) with data map',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: 'Text(user.name)',
            config: RuneConfig.defaults(),
            data: const {
              'user': {'name': 'Ali'},
            },
          ),
        ),
      );
      expect(find.text('Ali'), findsOneWidget);
    });
  });
}
