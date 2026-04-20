# Changelog

All notable changes to `rune_cupertino` are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-19

### Added
- Initial release. `CupertinoBridge` implements `RuneBridge` and registers
  a curated slice of Flutter's Cupertino widget set on a `RuneConfig`.
- Widget builders (10): `CupertinoApp`, `CupertinoPageScaffold`,
  `CupertinoNavigationBar`, `CupertinoButton`, `CupertinoSwitch`,
  `CupertinoSlider`, `CupertinoTextField`, `CupertinoActivityIndicator`,
  `CupertinoAlertDialog`, `CupertinoDialogAction`.
- Value builder (1): `CupertinoThemeData` (default constructor) with
  `brightness`, `primaryColor`, `primaryContrastingColor`,
  `scaffoldBackgroundColor`, and `barBackgroundColor` arguments.
- Constants (30): `CupertinoIcons.*` entries covering navigation,
  common actions, content surfaces, and communications.
- Seventy-two tests: bridge registration, per-widget arg forwarding and
  event-dispatch paths, theme data builder, icon registry seed, and
  end-to-end `RuneView` smokes through a `CupertinoApp` host.
- Analyzer-clean under `very_good_analysis ^5.1.0`.
