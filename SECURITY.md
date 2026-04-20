# Security policy

## Supported versions

Rune is a young package on a rolling 1.x release cadence. Only the latest minor is actively patched for security issues:

| Version  | Supported |
| -------- | --------- |
| 1.15.x   | yes       |
| 1.14.x   | yes (last minor) |
| 1.13.x and older | no        |
| 0.x      | no        |

Sibling bridge packages (`rune_cupertino`, `rune_provider`, `rune_router`, `rune_responsive_sizer`) follow the same policy on their own version tracks: only the latest minor is patched.

## Threat model

Rune interprets a **constrained subset of Dart expression syntax** against a whitelist of registered widget / value / constant / extension builders. It explicitly does not:

- Execute arbitrary Dart code.
- Use `dart:mirrors`.
- Use `eval` or similar dynamic evaluation.
- Generate Dart code on-device.

Inputs are parsed with `package:analyzer` and walked as an AST; anything outside the registered whitelist raises a `RuneException`. The threat model is therefore narrower than a full Dart runtime: Rune cannot open sockets, spawn isolates, read files, or perform any operation that is not exposed through a registered builder.

Security-relevant invariants to preserve when contributing:

- Builders must never invoke other builders directly. Only the resolver walks the AST. A builder that reflected into the resolver could bypass the whitelist.
- `ResolvedArguments` accessors (`.get<T>`, `.require<T>`, `.positionalAt<T>`) must stay type-safe. An accessor returning `dynamic` would broaden what source can reach.
- `RuneContext` stays `@immutable`. A mutable context would let one builder smuggle state to another and evade the "no side effects outside builders" contract.
- Host-supplied data is passed through `RuneDataContext`; the context wraps user input in `Map.unmodifiable` to prevent a builder from mutating host state.

## Reporting a vulnerability

**Do not open a public GitHub issue.** Send a private report to **can.arslan@nodelabs.software** with:

- A short description of the vulnerability.
- A minimal reproduction: the exact `RuneView.source` string, `data` map, and `RuneConfig` (defaults or bridges applied) that demonstrates it.
- The rune version and Flutter version (`flutter --version`).
- Whether the issue is local to the Rune engine or involves a specific sibling bridge.

Expect a reply within **5 business days** acknowledging receipt. From there:

- Triage: within 7 days of receipt, we confirm whether the report is a security issue or a regular bug.
- Fix: within 30 days of confirmation for critical issues (sandbox escape, data leakage, undefined Dart behavior); best-effort for lower-severity issues.
- Disclosure: coordinated. We will credit the reporter (unless you prefer anonymity) in the patch release notes once a fix has been shipped and users have had a reasonable window to upgrade.

If you have already published a report publicly by mistake, contact the maintainer immediately so we can coordinate a patch release.

## Bug-bounty

Rune does not currently operate a bug-bounty program. Credit in release notes and a public thank-you are the only rewards offered.
