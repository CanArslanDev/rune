import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoTextField] with two-way value binding that mirrors
/// the Material `TextField` bridge.
///
/// Source arguments (all optional):
/// - `controller` ([TextEditingController]) - externally-owned. When
///   supplied, the internal controller is bypassed entirely and
///   disposal stays with the source-level owner. The `value` arg is
///   ignored in this mode.
/// - `value` (`String`) - initial/current text for the internal-
///   controller mode. Re-sync without moving the cursor happens only
///   when the incoming text genuinely differs from what the controller
///   already shows.
/// - `onChanged` (`String` or closure) - receives the new text on each
///   keystroke. Missing `onChanged` keeps the field locally editable
///   but the host is never notified.
/// - `placeholder` (`String`) - placeholder shown when empty.
/// - `obscureText` (`bool`) - defaults to `false`.
/// - `maxLines` (`int?`) - defaults to `1`. Explicit `null` enables
///   multiline growth.
/// - `enabled` (`bool`) - defaults to `true`.
/// - `focusNode` ([FocusNode]) - externally-owned node; absence lets
///   Flutter create its own.
final class CupertinoTextFieldBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless; the controller lives
  /// inside the returned stateful wrapper.
  const CupertinoTextFieldBuilder();

  @override
  String get typeName => 'CupertinoTextField';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return _RuneCupertinoTextField(
      value: args.get<String>('value'),
      externalController: args.get<TextEditingController>('controller'),
      focusNode: args.get<FocusNode>('focusNode'),
      onChangedSource: args.named['onChanged'],
      placeholder: args.get<String>('placeholder'),
      obscureText: args.getOr<bool>('obscureText', false),
      maxLines: args.named.containsKey('maxLines')
          ? args.get<int>('maxLines')
          : 1,
      enabled: args.getOr<bool>('enabled', true),
      dispatcher: ctx.events,
    );
  }
}

class _RuneCupertinoTextField extends StatefulWidget {
  const _RuneCupertinoTextField({
    required this.value,
    required this.externalController,
    required this.focusNode,
    required this.onChangedSource,
    required this.placeholder,
    required this.obscureText,
    required this.maxLines,
    required this.enabled,
    required this.dispatcher,
  });

  final String? value;
  final TextEditingController? externalController;
  final FocusNode? focusNode;
  final Object? onChangedSource;
  final String? placeholder;
  final bool obscureText;
  final int? maxLines;
  final bool enabled;
  final RuneEventDispatcher dispatcher;

  @override
  State<_RuneCupertinoTextField> createState() =>
      _RuneCupertinoTextFieldState();
}

class _RuneCupertinoTextFieldState extends State<_RuneCupertinoTextField> {
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
  void didUpdateWidget(_RuneCupertinoTextField old) {
    super.didUpdateWidget(old);
    final wasExternal = old.externalController != null;
    final isExternal = widget.externalController != null;

    if (wasExternal && !isExternal) {
      _internal = TextEditingController(text: widget.value ?? '');
      return;
    }

    if (!wasExternal && isExternal) {
      _internal?.dispose();
      _internal = null;
      return;
    }

    if (!isExternal) {
      final incoming = widget.value ?? '';
      if (incoming != _controller.text) {
        _controller.value = TextEditingValue(
          text: incoming,
          selection: TextSelection.collapsed(offset: incoming.length),
        );
      }
      return;
    }
  }

  @override
  void dispose() {
    _internal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _controller,
      focusNode: widget.focusNode,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      placeholder: widget.placeholder,
      onChanged: valueEventCallback<String>(
        widget.onChangedSource,
        widget.dispatcher,
      ),
    );
  }
}
