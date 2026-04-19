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

/// Validates a resolved lifecycle-hook argument (`initState`, `dispose`,
/// `didUpdateWidget`) for `StatefulBuilder`.
///
/// Returns `null` when [rawClosure] is `null`. Every lifecycle hook is
/// optional. Returns a plain Dart invoker otherwise that feeds a single
/// [RuneState] argument into the underlying [RuneClosure].
///
/// [paramName] is the name of the named argument (e.g. `'dispose'`); it
/// is used only for error-message construction so a diagnostic reads
/// `dispose closure must accept ...`.
///
/// Throws [ArgumentException] when [rawClosure] is present but not a
/// [RuneClosure] or declares an arity other than 1.
Object? Function(RuneState)? validateStatefulBuilderLifecycleClosure(
  Object? rawClosure, {
  required String paramName,
}) {
  if (rawClosure == null) return null;
  if (rawClosure is! RuneClosure) {
    throw ArgumentException(
      'StatefulBuilder',
      '`$paramName` must be a closure (state) => ...; got '
      '${rawClosure.runtimeType}',
    );
  }
  if (rawClosure.parameterNames.length != 1) {
    throw ArgumentException(
      'StatefulBuilder',
      '`$paramName` closure must accept exactly one parameter '
      '(the state), got ${rawClosure.parameterNames.length}',
    );
  }
  return (state) => rawClosure.call(<Object?>[state]);
}
