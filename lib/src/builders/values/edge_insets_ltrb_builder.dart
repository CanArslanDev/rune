import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart' show ArgumentException;
import 'package:rune/src/core/rune_context.dart';

/// Builds `EdgeInsets.fromLTRB(left, top, right, bottom)` from four
/// required positional numeric arguments.
final class EdgeInsetsFromLTRBBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const EdgeInsetsFromLTRBBuilder();

  @override
  String get typeName => 'EdgeInsets';

  @override
  String? get constructorName => 'fromLTRB';

  /// Builds an [EdgeInsets.fromLTRB] from four positional [num] arguments
  /// at indices 0–3. Throws [ArgumentException] if any index is absent.
  @override
  EdgeInsets build(ResolvedArguments args, RuneContext ctx) {
    final l = args.requirePositional<num>(0, source: 'EdgeInsets.fromLTRB');
    final t = args.requirePositional<num>(1, source: 'EdgeInsets.fromLTRB');
    final r = args.requirePositional<num>(2, source: 'EdgeInsets.fromLTRB');
    final bot = args.requirePositional<num>(3, source: 'EdgeInsets.fromLTRB');
    return EdgeInsets.fromLTRB(
      l.toDouble(),
      t.toDouble(),
      r.toDouble(),
      bot.toDouble(),
    );
  }
}
