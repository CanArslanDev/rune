---
name: Bridge proposal
about: Propose a new sibling bridge package (e.g. rune_firebase, rune_bloc)
title: "[bridge] rune_<name>: "
labels: bridge, enhancement
assignees: ''
---

## Bridge name

`rune_<name>` (lowercase, snake_case, matches the wrapped package where possible).

## What it wraps

The Flutter / Dart package(s) this bridge surfaces into Rune source. Link them on pub.dev.

## What Rune source gains

Concrete API sketch:

```
// What Rune source would look like with this bridge applied
YourNewWidget(arg: 42, onSomething: 'event-name')
```

## Widget / value / constant / extension breakdown

| Contribution    | Type name              | Backing Flutter class   | Notes                               |
| --------------- | ---------------------- | ----------------------- | ----------------------------------- |
| widget          | `Foo`                  | `package:x/Foo`         | Required args; events; etc.         |
| value           | `Bar.baz(...)`         | `package:x/Bar.baz`     | Positional or named ctor?           |
| constant group  | `Qux.*` (enum)         | `package:x/Qux`         | Value list.                         |
| extension       | `.something` on `num`  | n/a                     | Host-side only; what it computes.   |

## Dependencies

What this bridge adds to the dependency graph (e.g. `go_router ^14`, `firebase_core ^2.x`). Note any Flutter floor concerns.

## Prior art

Similar integrations in other server-driven-UI frameworks, if any. Helps calibrate API shape.

## Adoption signal

Roughly how many Rune users would actually use this? Link an issue or discussion if there's demand. Bridges with no adoption signal tend to stay in planning indefinitely.

## Willing to land it yourself?

- [ ] Yes - I will open a PR implementing this proposal.
- [ ] Yes, with guidance - I can pair if someone scopes the initial design.
- [ ] No - leaving it for the maintainer / community.

Maintainers are more likely to green-light a bridge proposal when a contributor is committed to the implementation.
