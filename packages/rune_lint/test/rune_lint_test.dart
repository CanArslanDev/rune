import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_lint/rune_lint.dart';

void main() {
  group('validateRuneSource', () {
    testWidgets('valid source returns empty list', (tester) async {
      final issues = await validateRuneSource(
        tester,
        "Text('hello')",
        RuneConfig.defaults(),
      );
      expect(issues, isEmpty);
    });

    testWidgets(
      'surfaces UnregisteredBuilderException as unregistered kind',
      (tester) async {
        final issues = await validateRuneSource(
          tester,
          'NoSuchWidget()',
          RuneConfig.defaults(),
        );
        expect(issues, hasLength(1));
        expect(issues.first.kind, RuneLintIssueKind.unregistered);
        expect(issues.first.message, contains('NoSuchWidget'));
      },
    );

    testWidgets(
      'surfaces missing-constant reference',
      (tester) async {
        final issues = await validateRuneSource(
          tester,
          'Icon(Icons.not_a_real_icon)',
          RuneConfig.defaults(),
        );
        expect(issues, isNotEmpty);
        expect(
          issues.any(
            (i) =>
                i.kind == RuneLintIssueKind.resolveError ||
                i.kind == RuneLintIssueKind.unregistered,
          ),
          isTrue,
        );
      },
    );

    testWidgets(
      'surfaces missing data key as missingBinding',
      (tester) async {
        final issues = await validateRuneSource(
          tester,
          'Text(username)',
          RuneConfig.defaults(),
        );
        expect(issues, hasLength(1));
        expect(issues.first.kind, RuneLintIssueKind.missingBinding);
        expect(issues.first.message, contains('username'));
      },
    );

    testWidgets(
      'data-bound source passes when data is supplied',
      (tester) async {
        final issues = await validateRuneSource(
          tester,
          'Text(username)',
          RuneConfig.defaults(),
          data: const {'username': 'Ali'},
        );
        expect(issues, isEmpty);
      },
    );

    testWidgets(
      'parse-level garbage surfaces as parseError',
      (tester) async {
        final issues = await validateRuneSource(
          tester,
          'this is !!! not @ dart syntax',
          RuneConfig.defaults(),
        );
        expect(issues, hasLength(1));
        expect(issues.first.kind, RuneLintIssueKind.parseError);
      },
    );
  });

  group('expectValidRuneSource', () {
    testWidgets('passes when no issues', (tester) async {
      await expectValidRuneSource(tester, "Text('ok')", RuneConfig.defaults());
    });

    testWidgets(
      'fails with a readable listing when issues exist',
      (tester) async {
        await expectLater(
          () => expectValidRuneSource(
            tester,
            'NoSuchWidget()',
            RuneConfig.defaults(),
          ),
          throwsA(isA<TestFailure>()),
        );
      },
    );

    testWidgets(
      'ignoreKinds suppresses selected categories',
      (tester) async {
        await expectValidRuneSource(
          tester,
          'Text(username)',
          RuneConfig.defaults(),
          ignoreKinds: const [RuneLintIssueKind.missingBinding],
        );
      },
    );
  });
}
