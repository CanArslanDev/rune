import 'package:flutter/material.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [TextField] with two-way value binding.
///
/// Source arguments (all optional):
/// - `value` (`String`) — initial/current text. Updates from the host's
///   `RuneView.data` re-sync the controller without moving the cursor
///   when the new text matches what the field already shows; a genuine
///   external change (e.g. the host cleared the field) resets the
///   selection to the end.
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
    required this.onChangedSource,
    required this.hintText,
    required this.labelText,
    required this.obscureText,
    required this.maxLines,
    required this.enabled,
    required this.dispatcher,
  });

  final String? value;
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
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(_RuneTextField old) {
    super.didUpdateWidget(old);
    // External update: the host's state changed and a new `value` is
    // flowing in via data. Only sync if the incoming value actually
    // differs from what the controller is already holding — otherwise
    // we would reset the cursor on every keystroke's rebuild.
    final incoming = widget.value ?? '';
    if (incoming != _controller.text) {
      _controller.value = TextEditingValue(
        text: incoming,
        selection: TextSelection.collapsed(offset: incoming.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
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
