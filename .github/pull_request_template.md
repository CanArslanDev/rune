## Summary

<!-- 1-3 sentences describing the change and why it's needed. -->

## Type of change

- [ ] feat (new user-visible behaviour)
- [ ] fix (bug fix)
- [ ] refactor (internal change, no behaviour delta)
- [ ] test (test-only change)
- [ ] docs (documentation-only change)
- [ ] chore (tooling, release plumbing)

## Checklist

- [ ] Tests added for new behaviour (RED then GREEN, in the same commit)
- [ ] `flutter test` passes at the repo root and (if applicable) in the
      sibling package under `packages/`
- [ ] `flutter analyze` reports 0 issues under `very_good_analysis ^5.1.0`
- [ ] `CHANGELOG.md` updated under `## [Unreleased]` for user-visible changes
- [ ] No `Co-Authored-By:` trailers in any commit message
- [ ] Architecture test (`test/architecture/import_flow_test.dart`) still
      passes; extended in this PR if a new layer or import boundary was added
