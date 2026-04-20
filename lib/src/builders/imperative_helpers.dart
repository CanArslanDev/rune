import 'package:flutter/material.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Top-level imperative bridges exposed to Rune source as bare calls:
///
/// - `showDialog(builder: (ctx) => AlertDialog(...), barrierDismissible: true)`
/// - `showModalBottomSheet(builder: (ctx) => Container(...))`
/// - `showSnackBar(SnackBar(content: Text('Hi')))`
/// - `Navigator.pop(optionalResult)`
///
/// The functions take already-resolved arguments and delegate to the
/// corresponding Flutter imperative API, reading the enclosing
/// [BuildContext] from [RuneContext.flutterContext]. A missing
/// `flutterContext` surfaces as [ResolveException] citing the bridge
/// name, because Rune source unit-tested outside a live widget tree
/// cannot honour imperative UI calls.
///
/// Each bridge returns the Flutter API's own return value (typically a
/// `Future<T?>`) so the resolver can pass it back as an [Object?]. Rune
/// source has no `await` syntax, so the Future is effectively ignored
/// today; the dialog/sheet still mounts and dismisses correctly because
/// Flutter's imperative surface fires its own lifecycle callbacks.
///
/// These are plain top-level functions rather than builders because
/// they do not produce a widget or a value that participates in a
/// widget tree; they return `null` or a `Future`. Dispatch happens in
/// `InvocationResolver` for a small whitelist of identifiers.

/// Resolves `showDialog(...)` into Flutter's imperative `showDialog`.
///
/// Accepts named arguments only:
/// - `builder` (required `RuneClosure` of arity 1) - receives a
///   [BuildContext] and returns the widget to mount.
/// - `barrierDismissible` ([bool]?). Defaults to `true`.
/// - `barrierColor` ([Color]?).
/// - `useSafeArea` ([bool]?). Defaults to `true`.
/// - `useRootNavigator` ([bool]?). Defaults to `true`.
///
/// Returns the `Future<Object?>` yielded by Flutter's `showDialog`.
Future<Object?> runShowDialog(ResolvedArguments args, RuneContext ctx) {
  final context = _requireFlutterContext(ctx, 'showDialog');
  final builder = toContextWidgetBuilder(
    args.named['builder'],
    'showDialog',
  );
  return showDialog<Object?>(
    context: context,
    builder: builder,
    barrierDismissible: args.getOr<bool>('barrierDismissible', true),
    barrierColor: args.get<Color>('barrierColor'),
    useSafeArea: args.getOr<bool>('useSafeArea', true),
    useRootNavigator: args.getOr<bool>('useRootNavigator', true),
  );
}

/// Resolves `showModalBottomSheet(...)` into Flutter's imperative
/// `showModalBottomSheet`.
///
/// Accepts named arguments only:
/// - `builder` (required `RuneClosure` of arity 1).
/// - `backgroundColor` ([Color]?).
/// - `isScrollControlled` ([bool]?). Defaults to `false`.
/// - `isDismissible` ([bool]?). Defaults to `true`.
/// - `enableDrag` ([bool]?). Defaults to `true`.
/// - `useSafeArea` ([bool]?). Defaults to `false`.
/// - `useRootNavigator` ([bool]?). Defaults to `false`.
/// - `elevation` ([num]? coerced to double).
///
/// Returns the `Future<Object?>` yielded by Flutter's
/// `showModalBottomSheet`.
Future<Object?> runShowModalBottomSheet(
  ResolvedArguments args,
  RuneContext ctx,
) {
  final context = _requireFlutterContext(ctx, 'showModalBottomSheet');
  final builder = toContextWidgetBuilder(
    args.named['builder'],
    'showModalBottomSheet',
  );
  return showModalBottomSheet<Object?>(
    context: context,
    builder: builder,
    backgroundColor: args.get<Color>('backgroundColor'),
    isScrollControlled: args.getOr<bool>('isScrollControlled', false),
    isDismissible: args.getOr<bool>('isDismissible', true),
    enableDrag: args.getOr<bool>('enableDrag', true),
    useSafeArea: args.getOr<bool>('useSafeArea', false),
    useRootNavigator: args.getOr<bool>('useRootNavigator', false),
    elevation: args.get<num>('elevation')?.toDouble(),
  );
}

/// Resolves `showSnackBar(snackBar)` into
/// `ScaffoldMessenger.of(context).showSnackBar(snackBar)`.
///
/// Expects exactly one positional argument of type [SnackBar]; anything
/// else raises [ArgumentException] citing the bridge name.
///
/// Returns the [ScaffoldFeatureController] yielded by
/// `ScaffoldMessenger.showSnackBar`, so source that stores the result
/// in a local can later call `controller.close()` if the runtime
/// member whitelist is extended; for v1.3.0 the result is typically
/// discarded.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> runShowSnackBar(
  ResolvedArguments args,
  RuneContext ctx,
) {
  final context = _requireFlutterContext(ctx, 'showSnackBar');
  final snackBar = args.requirePositional<SnackBar>(
    0,
    source: 'showSnackBar',
  );
  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// Resolves `Navigator.pop(optionalResult)` into
/// `Navigator.of(context).pop(result)`.
///
/// Accepts at most one positional argument (the pop result). Named
/// arguments raise [ArgumentException]. Returns `null` (Flutter's
/// `Navigator.pop` is void).
Object? runNavigatorPop(ResolvedArguments args, RuneContext ctx) {
  final context = _requireFlutterContext(ctx, 'Navigator.pop');
  if (args.named.isNotEmpty) {
    throw ArgumentException(
      'Navigator.pop',
      'Navigator.pop does not accept named arguments; got '
      '${args.named.keys.join(', ')}',
    );
  }
  if (args.positional.length > 1) {
    throw ArgumentException(
      'Navigator.pop',
      'Navigator.pop accepts at most one positional argument (result); '
      'got ${args.positional.length}',
    );
  }
  final result = args.positional.isEmpty ? null : args.positional[0];
  Navigator.of(context).pop(result);
  return null;
}

/// Resolves `Navigator.push(route)` into `Navigator.of(context).push(route)`.
///
/// Accepts exactly one positional argument of type [Route]. Named
/// arguments raise [ArgumentException]; any other positional shape raises
/// [ResolveException] citing the bridge name. Returns `null` (Flutter's
/// `Navigator.push` returns a `Future<T?>`; Rune source has no `await`
/// syntax today and the future is intentionally discarded).
Object? runNavigatorPush(ResolvedArguments args, RuneContext ctx) {
  final context = _requireFlutterContext(ctx, 'Navigator.push');
  if (args.named.isNotEmpty) {
    throw ArgumentException(
      'Navigator.push',
      'Navigator.push does not accept named arguments; got '
      '${args.named.keys.join(', ')}',
    );
  }
  if (args.positional.length != 1) {
    throw ResolveException(
      'Navigator.push',
      'Navigator.push expects exactly one positional Route argument; '
      'got ${args.positional.length}',
    );
  }
  final candidate = args.positional[0];
  if (candidate is! Route<Object?>) {
    throw ResolveException(
      'Navigator.push',
      'Navigator.push expects a Route (e.g. MaterialPageRoute, '
      'CupertinoPageRoute); got ${candidate.runtimeType}',
    );
  }
  // Fire-and-forget: the returned Future<T?> cannot be awaited from Rune
  // source today. The route still mounts and dismisses correctly because
  // Flutter's Navigator handles its own lifecycle.
  Navigator.of(context).push<Object?>(candidate);
  return null;
}

/// Resolves `Navigator.pushReplacement(route)` into
/// `Navigator.of(context).pushReplacement(route)`.
///
/// Identical contract to [runNavigatorPush]: exactly one positional
/// [Route] argument, no named arguments. Returns `null`.
Object? runNavigatorPushReplacement(ResolvedArguments args, RuneContext ctx) {
  final context = _requireFlutterContext(ctx, 'Navigator.pushReplacement');
  if (args.named.isNotEmpty) {
    throw ArgumentException(
      'Navigator.pushReplacement',
      'Navigator.pushReplacement does not accept named arguments; got '
      '${args.named.keys.join(', ')}',
    );
  }
  if (args.positional.length != 1) {
    throw ResolveException(
      'Navigator.pushReplacement',
      'Navigator.pushReplacement expects exactly one positional Route '
      'argument; got ${args.positional.length}',
    );
  }
  final candidate = args.positional[0];
  if (candidate is! Route<Object?>) {
    throw ResolveException(
      'Navigator.pushReplacement',
      'Navigator.pushReplacement expects a Route (e.g. MaterialPageRoute, '
      'CupertinoPageRoute); got ${candidate.runtimeType}',
    );
  }
  Navigator.of(context).pushReplacement<Object?, Object?>(candidate);
  return null;
}

/// Resolves `Navigator.pushNamed(name, arguments?)` into
/// `Navigator.of(context).pushNamed(name, arguments: arguments)`.
///
/// Accepts:
/// - exactly one positional argument: the route name ([String]).
/// - one optional named argument `arguments` of any type (mirrors
///   Flutter's `RouteSettings.arguments`).
///
/// Any other named argument raises [ArgumentException]; wrong positional
/// count or a non-[String] name raises [ResolveException] citing the
/// bridge name. Returns `null` (the returned `Future<T?>` is discarded).
Object? runNavigatorPushNamed(ResolvedArguments args, RuneContext ctx) {
  final context = _requireFlutterContext(ctx, 'Navigator.pushNamed');
  for (final key in args.named.keys) {
    if (key != 'arguments') {
      throw ArgumentException(
        'Navigator.pushNamed',
        'Navigator.pushNamed only accepts the named argument "arguments"; '
        'got "$key"',
      );
    }
  }
  if (args.positional.length != 1) {
    throw ResolveException(
      'Navigator.pushNamed',
      'Navigator.pushNamed expects exactly one positional String argument '
      '(the route name); got ${args.positional.length}',
    );
  }
  final name = args.positional[0];
  if (name is! String) {
    throw ResolveException(
      'Navigator.pushNamed',
      'Navigator.pushNamed expects a String route name; '
      'got ${name.runtimeType}',
    );
  }
  Navigator.of(context).pushNamed<Object?>(
    name,
    arguments: args.named['arguments'],
  );
  return null;
}

/// Resolves `Navigator.canPop()` into `Navigator.of(context).canPop()`.
///
/// Accepts no arguments. Returns a [bool] indicating whether the enclosing
/// [Navigator] has at least one route on the stack above the initial
/// route. Callers typically use it to guard an `if`-element that only
/// shows a back button when popping is possible.
Object? runNavigatorCanPop(ResolvedArguments args, RuneContext ctx) {
  final context = _requireFlutterContext(ctx, 'Navigator.canPop');
  if (args.named.isNotEmpty || args.positional.isNotEmpty) {
    throw ArgumentException(
      'Navigator.canPop',
      'Navigator.canPop accepts no arguments; got '
      '${args.positional.length} positional and '
      '${args.named.length} named',
    );
  }
  return Navigator.of(context).canPop();
}

/// Resolves `showDatePicker(...)` into Flutter's imperative
/// `showDatePicker`.
///
/// Accepts named arguments only:
/// - `initialDate` ([DateTime], required).
/// - `firstDate` ([DateTime], required).
/// - `lastDate` ([DateTime], required).
/// - `helpText`, `cancelText`, `confirmText`, `errorFormatText`,
///   `errorInvalidText`, `fieldHintText`, `fieldLabelText` ([String]?).
///
/// Returns the `Future<DateTime?>` yielded by Flutter's `showDatePicker`.
/// Rune source has no `await` syntax, so the returned Future is typically
/// ignored; the picker still mounts and dismisses correctly because
/// Flutter's imperative surface fires its own lifecycle callbacks.
Future<DateTime?> runShowDatePicker(
  ResolvedArguments args,
  RuneContext ctx,
) {
  final context = _requireFlutterContext(ctx, 'showDatePicker');
  return showDatePicker(
    context: context,
    initialDate: args.require<DateTime>(
      'initialDate',
      source: 'showDatePicker',
    ),
    firstDate: args.require<DateTime>(
      'firstDate',
      source: 'showDatePicker',
    ),
    lastDate: args.require<DateTime>(
      'lastDate',
      source: 'showDatePicker',
    ),
    helpText: args.get<String>('helpText'),
    cancelText: args.get<String>('cancelText'),
    confirmText: args.get<String>('confirmText'),
    errorFormatText: args.get<String>('errorFormatText'),
    errorInvalidText: args.get<String>('errorInvalidText'),
    fieldHintText: args.get<String>('fieldHintText'),
    fieldLabelText: args.get<String>('fieldLabelText'),
  );
}

/// Resolves `showTimePicker(...)` into Flutter's imperative
/// `showTimePicker`.
///
/// Accepts named arguments only:
/// - `initialTime` ([TimeOfDay], required).
/// - `helpText`, `cancelText`, `confirmText`, `hourLabelText`,
///   `minuteLabelText` ([String]?).
///
/// Returns the `Future<TimeOfDay?>` yielded by Flutter's
/// `showTimePicker`. Rune source has no `await` syntax, so the returned
/// Future is typically ignored.
Future<TimeOfDay?> runShowTimePicker(
  ResolvedArguments args,
  RuneContext ctx,
) {
  final context = _requireFlutterContext(ctx, 'showTimePicker');
  return showTimePicker(
    context: context,
    initialTime: args.require<TimeOfDay>(
      'initialTime',
      source: 'showTimePicker',
    ),
    helpText: args.get<String>('helpText'),
    cancelText: args.get<String>('cancelText'),
    confirmText: args.get<String>('confirmText'),
    hourLabelText: args.get<String>('hourLabelText'),
    minuteLabelText: args.get<String>('minuteLabelText'),
  );
}

/// Shared guard: reads [RuneContext.flutterContext] or raises
/// [ResolveException] citing [bridgeName] so unit tests without a live
/// widget tree get an actionable diagnostic rather than a null-deref.
BuildContext _requireFlutterContext(RuneContext ctx, String bridgeName) {
  final context = ctx.flutterContext;
  if (context == null) {
    throw ResolveException(
      bridgeName,
      '$bridgeName requires an enclosing BuildContext; '
      'RuneContext.flutterContext is null. This typically means the '
      'call was made outside a live RuneView render.',
    );
  }
  return context;
}
