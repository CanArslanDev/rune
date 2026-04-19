import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_state.dart';
import 'package:rune/src/resolver/rune_closure.dart';

/// Validates a resolved `builder` argument for `StatefulBuilder` and
/// returns a plain Dart invoker that feeds a [RuneState] into the
/// underlying [RuneClosure].
///
/// Lives in the `builders/` root rather than in
/// `builders/widgets/stateful_builder_builder.dart` because the
/// architecture invariant forbids `builders/widgets/` from importing
/// `src/resolver/`. The single permitted resolver import from
/// `builders/` root is [RuneClosure] itself (see also
/// `event_callback.dart`), so the gate for closure-shaped args belongs
/// here.
///
/// Throws [ArgumentException] when [rawBuilder] is `null`, not a
/// [RuneClosure], or a closure with an arity other than 1.
Object? Function(RuneState) validateStatefulBuilderClosure(
  Object? rawBuilder,
) {
  if (rawBuilder == null) {
    throw const ArgumentException(
      'StatefulBuilder',
      'Missing required argument "builder"',
    );
  }
  if (rawBuilder is! RuneClosure) {
    throw ArgumentException(
      'StatefulBuilder',
      '`builder` must be a closure (state) => Widget; got '
      '${rawBuilder.runtimeType}',
    );
  }
  if (rawBuilder.parameterNames.length != 1) {
    throw ArgumentException(
      'StatefulBuilder',
      '`builder` closure must accept exactly one parameter '
      '(the state), got ${rawBuilder.parameterNames.length}',
    );
  }
  return (state) => rawBuilder.call(<Object?>[state]);
}
