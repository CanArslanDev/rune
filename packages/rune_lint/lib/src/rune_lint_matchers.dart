import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_lint/src/rune_lint_issue.dart';
import 'package:rune_lint/src/rune_source_validator.dart';

/// Convenience wrapper over [validateRuneSource] + `fail` that
/// passes when no issues are found and fails with a readable
/// listing otherwise.
///
/// Intended for inline use inside `testWidgets`:
///
/// ```dart
/// testWidgets('home.rune renders cleanly', (tester) async {
///   await expectValidRuneSource(tester, homeSource, RuneConfig.defaults());
/// });
/// ```
///
/// Pass [data] when the source depends on a data map (the
/// validator surfaces missing-binding errors if you skip this for
/// source that uses identifiers).
///
/// Pass [ignoreKinds] to skip categories that are expected during
/// the validation pass.
Future<void> expectValidRuneSource(
  WidgetTester tester,
  String source,
  RuneConfig config, {
  Map<String, Object?> data = const <String, Object?>{},
  Iterable<RuneLintIssueKind> ignoreKinds = const <RuneLintIssueKind>[],
}) async {
  final issues = await validateRuneSource(tester, source, config, data: data);
  final filtered = issues
      .where((issue) => !ignoreKinds.contains(issue.kind))
      .toList(growable: false);
  if (filtered.isEmpty) return;
  final buffer = StringBuffer(
    'Expected valid Rune source, got ${filtered.length} issue(s):',
  );
  for (final issue in filtered) {
    buffer.write('\n  - $issue');
  }
  fail(buffer.toString());
}
