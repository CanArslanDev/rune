import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoActionSheet], the iOS-style bottom modal typically
/// shown via `showCupertinoModalPopup(...)`.
///
/// Flutter asserts at construction that at least one of `title`,
/// `message`, `actions`, or `cancelButton` is non-null. Rune does not
/// pre-validate that rule; consumers that break it see the underlying
/// assertion surface through `RuneView.onError`.
///
/// Supported named arguments:
/// - `title` ([Widget]?) - title row (typically bold when `message`
///   is also supplied).
/// - `message` ([Widget]?) - descriptive body row.
/// - `actions` (`List<Widget>?`) - action buttons (typically
///   [CupertinoActionSheetAction]). Non-[Widget] entries are silently
///   dropped, matching the Column/Row children-filter convention. If
///   no actions are provided, the slot stays `null` so the assertion
///   above can trigger when the other slots are also absent.
/// - `cancelButton` ([Widget]?) - trailing cancel affordance.
final class CupertinoActionSheetBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoActionSheetBuilder();

  @override
  String get typeName => 'CupertinoActionSheet';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawActions = args.get<List<Object?>>('actions');
    final actions =
        rawActions?.whereType<Widget>().toList(growable: false);
    return CupertinoActionSheet(
      title: args.get<Widget>('title'),
      message: args.get<Widget>('message'),
      actions: actions,
      cancelButton: args.get<Widget>('cancelButton'),
    );
  }
}
