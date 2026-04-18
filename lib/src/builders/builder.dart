import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Root interface for any object that can produce a Dart value from
/// resolved arguments and a [RuneContext]. Implementations are keyed by
/// [typeName] in the relevant registry.
abstract interface class RuneBuilder {
  /// The unqualified type name this builder represents
  /// (e.g. `"Text"`, `"EdgeInsets"`).
  String get typeName;

  /// Builds the concrete value.
  Object? build(ResolvedArguments args, RuneContext ctx);
}

/// A builder that produces a Flutter [Widget].
abstract interface class RuneWidgetBuilder implements RuneBuilder {
  @override
  Widget build(ResolvedArguments args, RuneContext ctx);
}

/// A builder that produces a non-widget value used as a constructor
/// argument (e.g. `EdgeInsets`, `TextStyle`, `Color`).
///
/// [constructorName] is `null` for the default constructor
/// (`TextStyle(...)`) and a string for named constructors
/// (`EdgeInsets.all(16)` → `constructorName == "all"`). The
/// `ValueRegistry` composes the lookup key as `typeName` or
/// `"typeName.constructorName"` accordingly.
abstract interface class RuneValueBuilder implements RuneBuilder {
  /// The named-constructor suffix, or `null` for the default constructor.
  String? get constructorName;
}
