import 'package:flutter/foundation.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `ValueKey(value)` from a single required positional argument.
///
/// Registered as a [RuneValueBuilder] under the default constructor
/// (`constructorName == null`), so source like `ValueKey('id-42')`
/// resolves directly to a Dart [ValueKey] instance.
///
/// The value is held as `ValueKey<Object>`: Rune source does not expose
/// generic type syntax, and the only consumers (`Dismissible` key,
/// `ReorderableListView` children) care about equality semantics, not
/// static type. Flutter's [Key] equality is delegated to the wrapped
/// value, which is the canonical use of [ValueKey] for stable list
/// identity.
///
/// Raises [ArgumentException] when the positional argument is absent or
/// `null`. A null key would defeat the identity purpose.
final class ValueKeyBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const ValueKeyBuilder();

  @override
  String get typeName => 'ValueKey';

  @override
  String? get constructorName => null;

  @override
  ValueKey<Object> build(ResolvedArguments args, RuneContext ctx) {
    final value = args.requirePositional<Object>(0, source: 'ValueKey');
    return ValueKey<Object>(value);
  }
}
