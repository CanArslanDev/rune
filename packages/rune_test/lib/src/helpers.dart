import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

/// The default `RuneConfig` used when a test does not supply one.
/// `RuneConfig.defaults()` is rebuilt per call so registries stay
/// isolated across tests.
RuneConfig defaultRuneTestConfig() => RuneConfig.defaults();

/// Pumps a minimal widget tree containing a `RuneView` and settles
/// all pending microtasks.
///
/// The tree is `MaterialApp` + `Scaffold` + [RuneView]; override
/// via [wrap] if you need a different chrome (for instance,
/// `CupertinoApp` or a `Localizations` wrapper).
///
/// [config] defaults to [defaultRuneTestConfig]. [data],
/// [onEvent], [onError], and [fallback] pass through to
/// `RuneView`. [settle] defaults to `true`; pass `false` to
/// return control immediately after the first frame (useful when
/// you need to inspect an in-flight render).
Future<void> pumpRuneView(
  WidgetTester tester,
  String source, {
  RuneConfig? config,
  Map<String, Object?>? data,
  void Function(String event, [List<Object?>? args])? onEvent,
  void Function(Object error, StackTrace stack)? onError,
  Widget? fallback,
  Widget Function(Widget child)? wrap,
  bool settle = true,
}) async {
  final view = RuneView(
    source: source,
    config: config ?? defaultRuneTestConfig(),
    data: data,
    onEvent: onEvent,
    onError: onError,
    fallback: fallback,
  );
  final wrapped = wrap == null
      ? MaterialApp(home: Scaffold(body: view))
      : wrap(view);
  await tester.pumpWidget(wrapped);
  if (settle) await tester.pumpAndSettle();
}

/// Pumps [source] through [pumpRuneView] and asserts that
/// [finder] matches [matcher] in the rendered tree.
///
/// ```dart
/// await expectRuneRenders(
///   tester,
///   "Text('Hello')",
///   find.text('Hello'),
///   findsOneWidget,
/// );
/// ```
///
/// Equivalent to [pumpRuneView] followed by
/// `expect(finder, matcher)`.
Future<void> expectRuneRenders(
  WidgetTester tester,
  String source,
  Finder finder,
  Matcher matcher, {
  RuneConfig? config,
  Map<String, Object?>? data,
  void Function(String event, [List<Object?>? args])? onEvent,
  Widget Function(Widget child)? wrap,
}) async {
  await pumpRuneView(
    tester,
    source,
    config: config,
    data: data,
    onEvent: onEvent,
    wrap: wrap,
  );
  expect(finder, matcher);
}
