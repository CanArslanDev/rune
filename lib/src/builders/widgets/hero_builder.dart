import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Hero] — matches the source/destination widgets of a cross-route
/// animation by their [Hero.tag].
///
/// Requires `tag` (any non-null [Object] — [String], [int], enum-ish keys
/// all work) and `child` (a [Widget]). Optional `transitionOnUserGestures`
/// (default `false`).
///
/// Two flavours of mistake raise distinct [ArgumentException] messages:
/// an absent `tag` and an explicit `tag: null`. Flutter's `Hero.tag` is
/// declared non-nullable, so both are user errors, but "missing" and
/// "present-but-null" are separately diagnosable and get separate
/// messages.
///
/// The builder-shaped arguments (`createRectTween`,
/// `flightShuttleBuilder`, `placeholderBuilder`) are out of scope — they
/// require function-literal support in Rune source, which lands in a
/// later phase.
final class HeroBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const HeroBuilder();

  @override
  String get typeName => 'Hero';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    if (!args.named.containsKey('tag')) {
      throw const ArgumentException(
        'Hero',
        'Missing required argument "tag"',
      );
    }
    final tag = args.named['tag'];
    if (tag == null) {
      throw const ArgumentException(
        'Hero',
        'Hero tag cannot be null — tags must be non-null to pair across '
            'routes',
      );
    }
    final child = args.require<Widget>('child', source: 'Hero');
    return Hero(
      tag: tag,
      transitionOnUserGestures: args.getOr<bool>(
        'transitionOnUserGestures',
        false,
      ),
      child: child,
    );
  }
}
