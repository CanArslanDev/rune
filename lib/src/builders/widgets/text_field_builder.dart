import 'package:flutter/material.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [TextField] with two-way value binding.
///
/// Source arguments (all optional):
/// - `controller` ([TextEditingController]): an externally-owned
///   controller constructed at source level (typically inside a
///   `StatefulBuilder(initial: {...})`). When supplied, the internal
///   controller is bypassed entirely: the external one drives text,
///   selection, and disposal stays with the source-level owner. The
///   `value` arg is ignored in this mode (external wins). When absent,
///   the builder creates and disposes its own controller.
/// - `value` (`String`): initial/current text for the internal-
///   controller mode. Updates from the host's `RuneView.data` re-sync
///   the internal controller without moving the cursor when the new
///   text matches what the field already shows; a genuine external
///   change (e.g. the host cleared the field) resets the selection to
///   the end. Ignored when `controller` is supplied.
/// - `onChanged` (`String` or closure): either a named-event String to
///   dispatch on each keystroke with the new text as the sole argument,
///   or a closure `(text) => ...` invoked with the new text on each
///   keystroke. Absence renders the field editable locally (the
///   controller still accepts input) but keeps [TextField.onChanged]
///   `null`, so the host is never notified.
/// - `hintText` (`String`) — placeholder shown when the field is empty.
/// - `labelText` (`String`) — floating label above the field.
/// - `obscureText` (`bool`) — `true` for password-style entry. Defaults
///   to `false`.
/// - `maxLines` (`int?`) — defaults to 1. Passing an explicit `null`
///   in source (`maxLines: null`) enables multiline growth; the
///   resolved value flows through unchanged.
/// - `enabled` (`bool`) — defaults to `true`.
/// - `focusNode` ([FocusNode]) — an externally-owned [FocusNode],
///   typically seeded in a `StatefulBuilder(initial: {...})` and
///   disposed via its `dispose` closure. When absent, Flutter creates
///   its own internal node (the historical v1.0 behavior).
///
/// Internally returns a private stateful wrapper that owns a
/// [TextEditingController] across `RuneView` rebuilds, so cursor
/// position survives every keystroke.
final class TextFieldBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless. The stateful
  /// controller lives inside the returned `_RuneTextField`.
  const TextFieldBuilder();

  @override
  String get typeName => 'TextField';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return _RuneTextField(
      value: args.get<String>('value'),
      externalController: args.get<TextEditingController>('controller'),
      focusNode: args.get<FocusNode>('focusNode'),
      onChangedSource: args.named['onChanged'],
      hintText: args.get<String>('hintText'),
      labelText: args.get<String>('labelText'),
      obscureText: args.getOr<bool>('obscureText', false),
      maxLines: args.named.containsKey('maxLines')
          ? args.get<int>('maxLines')
          : 1,
      enabled: args.getOr<bool>('enabled', true),
      dispatcher: ctx.events,
    );
  }
}

class _RuneTextField extends StatefulWidget {
  const _RuneTextField({
    required this.value,
    required this.externalController,
    required this.focusNode,
    required this.onChangedSource,
    required this.hintText,
    required this.labelText,
    required this.obscureText,
    required this.maxLines,
    required this.enabled,
    required this.dispatcher,
  });

  final String? value;
  final TextEditingController? externalController;
  final FocusNode? focusNode;
  final Object? onChangedSource;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final int? maxLines;
  final bool enabled;
  final RuneEventDispatcher dispatcher;

  @override
  State<_RuneTextField> createState() => _RuneTextFieldState();
}

class _RuneTextFieldState extends State<_RuneTextField> {
  // Internal controller is created only when no external one is supplied.
  // When the source supplies a controller, disposal is the source-level
  // owner's responsibility (typically StatefulBuilder dispose closure or
  // autoDisposeListenables).
  TextEditingController? _internal;

  TextEditingController get _controller =>
      widget.externalController ?? _internal!;

  @override
  void initState() {
    super.initState();
    if (widget.externalController == null) {
      _internal = TextEditingController(text: widget.value ?? '');
    }
  }

  @override
  void didUpdateWidget(_RuneTextField old) {
    super.didUpdateWidget(old);
    final wasExternal = old.externalController != null;
    final isExternal = widget.externalController != null;

    if (wasExternal && !isExternal) {
      // External -> internal: spin up a fresh internal controller seeded
      // from the incoming `value` (or empty).
      _internal = TextEditingController(text: widget.value ?? '');
      return;
    }

    if (!wasExternal && isExternal) {
      // Internal -> external: dispose the internal controller we owned.
      _internal?.dispose();
      _internal = null;
      return;
    }

    if (!isExternal) {
      // Both before and after were internal. Mirror the original sync
      // semantics: only resync when the incoming `value` genuinely
      // differs from what the controller is already holding, to avoid
      // resetting the cursor on every keystroke's rebuild.
      final incoming = widget.value ?? '';
      if (incoming != _controller.text) {
        _controller.value = TextEditingValue(
          text: incoming,
          selection: TextSelection.collapsed(offset: incoming.length),
        );
      }
      return;
    }

    // Both before and after were external: the source owns the
    // controller's text; we do not touch it.
  }

  @override
  void dispose() {
    // Only dispose the controller we created ourselves. External
    // controllers are owned by the source-level scope.
    _internal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
      ),
      onChanged: valueEventCallback<String>(
        widget.onChangedSource,
        widget.dispatcher,
      ),
    );
  }
}
