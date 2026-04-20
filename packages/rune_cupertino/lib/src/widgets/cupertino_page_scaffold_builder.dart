import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoPageScaffold], the iOS-style page surface.
///
/// Supported named arguments:
/// - `child` ([Widget], required) - main page content.
/// - `navigationBar` ([Widget]?) - typically a
///   [CupertinoNavigationBar]. A plain `Widget` resolved to something
///   that isn't an [ObstructingPreferredSizeWidget] is silently dropped,
///   mirroring `ScaffoldBuilder`'s AppBar-shape filter.
/// - `backgroundColor` ([Color]?) - scaffold background.
final class CupertinoPageScaffoldBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoPageScaffoldBuilder();

  @override
  String get typeName => 'CupertinoPageScaffold';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawNav = args.get<Widget>('navigationBar');
    return CupertinoPageScaffold(
      navigationBar:
          rawNav is ObstructingPreferredSizeWidget ? rawNav : null,
      backgroundColor: args.get<Color>('backgroundColor'),
      child: args.require<Widget>('child', source: 'CupertinoPageScaffold'),
    );
  }
}
