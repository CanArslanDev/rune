## Summary

<!-- 1-3 sentences describing the change and why it's needed. -->

## Type of change

- [ ] feat (new user-visible behavior)
- [ ] fix (bug fix)
- [ ] refactor (internal change, no behavior delta)
- [ ] test (test-only change)
- [ ] docs (documentation-only change)
- [ ] chore (tooling, release plumbing)

## Checklist

- [ ] Tests added for new behavior (RED then GREEN, in the same commit)
- [ ] `flutter test` passes at the repo root and (if applicable) in any sibling package under `packages/`
- [ ] `flutter analyze` reports 0 issues under `very_good_analysis ^5.1.0`
- [ ] Test file path mirrors production path (`lib/src/builders/widgets/foo_builder.dart` -> `test/builders/foo_builder_test.dart`)
- [ ] `test/architecture/import_flow_test.dart` still passes; extended in this PR if a new layer or import boundary was added
- [ ] `CHANGELOG.md` updated under `## [Unreleased]` for any user-visible change (skip for pure refactors / internal tests / docs-only)
- [ ] No em-dashes (`—`) or en-dashes (`–`) in user-facing markdown (README, CHANGELOG, example README, package READMEs, this PR body). Dart source comments and dartdoc are exempt.
- [ ] No `Co-Authored-By:` trailers in any commit message

## Context / screenshots

<!-- Link related issues with "Closes #N". For UI-affecting changes, attach a screenshot or a short video. -->

## Notes for reviewers

<!-- Anything surprising, risky, or non-obvious about the change. Version-drift gotchas, Flutter 3.24 CI floor concerns, deferred scope, etc. -->
