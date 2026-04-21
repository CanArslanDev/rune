import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_lint/src/rune_lint_issue.dart';

/// Dry-runs `RuneView` against [source] + [config] inside the
/// supplied [tester] and returns any `RuneException`s that surface
/// during the first render.
///
/// Implementation note: the validator reuses `RuneView` itself,
/// which means it catches every error path the real render would
/// hit (parse, resolve, missing binding, invalid argument,
/// non-Widget root) rather than duplicating the dispatch logic.
///
/// Requires an active `WidgetTester`; call from inside
/// `testWidgets(...)`. Pass an empty data map by default; supply a
/// real one via [data] to validate source that references data
/// keys (otherwise those surface as
/// [RuneLintIssueKind.missingBinding]).
Future<List<RuneLintIssue>> validateRuneSource(
  WidgetTester tester,
  String source,
  RuneConfig config, {
  Map<String, Object?> data = const <String, Object?>{},
}) async {
  final issues = <RuneLintIssue>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RuneView(
          source: source,
          config: config,
          data: data,
          onError: (error, _) => issues.add(_classify(error)),
          fallback: const SizedBox.shrink(),
        ),
      ),
    ),
  );
  return issues;
}

RuneLintIssue _classify(Object error) {
  if (error is UnregisteredBuilderException) {
    return RuneLintIssue(
      kind: RuneLintIssueKind.unregistered,
      message: error.toString(),
      offendingSource: error.source,
      line: error.location?.line,
      column: error.location?.column,
    );
  }
  if (error is ArgumentException) {
    return RuneLintIssue(
      kind: RuneLintIssueKind.invalidArgument,
      message: error.toString(),
      offendingSource: error.source,
      line: error.location?.line,
      column: error.location?.column,
    );
  }
  if (error is BindingException) {
    return RuneLintIssue(
      kind: RuneLintIssueKind.missingBinding,
      message: error.toString(),
      offendingSource: error.source,
      line: error.location?.line,
      column: error.location?.column,
    );
  }
  if (error is ParseException) {
    return RuneLintIssue(
      kind: RuneLintIssueKind.parseError,
      message: error.toString(),
      offendingSource: error.source,
      line: error.location?.line,
      column: error.location?.column,
    );
  }
  if (error is ResolveException) {
    return RuneLintIssue(
      kind: RuneLintIssueKind.resolveError,
      message: error.toString(),
      offendingSource: error.source,
      line: error.location?.line,
      column: error.location?.column,
    );
  }
  return RuneLintIssue(
    kind: RuneLintIssueKind.resolveError,
    message: 'Unexpected error type: ${error.runtimeType}: $error',
  );
}
