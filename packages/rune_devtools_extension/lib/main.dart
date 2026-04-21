import 'dart:convert';

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

/// Entry point of the Flutter web app that renders inside the
/// DevTools "rune" tab.
///
/// v0.2.0 (DevTools Phase 3) adds hot-edit: every card has an
/// Edit button that opens a source editor; Apply pushes the new
/// source to the host via `ext.rune.edit`, which the host applies
/// as an override on the matching `RuneView` until the user taps
/// Reset (which calls `ext.rune.reset`).
///
/// Refresh is manual. Tap the toolbar Refresh button to re-query
/// `ext.rune.inspect`.
void main() {
  runApp(const DevToolsExtension(child: _RuneInspectorApp()));
}

class _RuneInspectorApp extends StatefulWidget {
  const _RuneInspectorApp();

  @override
  State<_RuneInspectorApp> createState() => _RuneInspectorAppState();
}

class _RuneInspectorAppState extends State<_RuneInspectorApp> {
  List<_ViewPayload> _views = const <_ViewPayload>[];
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.rune.inspect',
      );
      final payload = response.json;
      if (payload == null) {
        throw StateError('Service extension returned no JSON.');
      }
      final raw = (payload['views'] as List<Object?>?) ?? const <Object?>[];
      final views = raw
          .cast<Map<String, Object?>>()
          .map(_ViewPayload.fromJson)
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _views = views;
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _applyEdit(int id, String newSource) async {
    try {
      await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.rune.edit',
        args: {'id': '$id', 'source': newSource},
      );
      await _refresh();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Edit failed: $e');
    }
  }

  Future<void> _resetEdit(int id) async {
    try {
      await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.rune.reset',
        args: {'id': '$id'},
      );
      await _refresh();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Reset failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rune inspector'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refresh,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _views.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorPane(message: _error!, onRetry: _refresh);
    }
    if (_views.isEmpty) {
      return const _EmptyPane();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _views.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ViewCard(
        view: _views[i],
        onApplyEdit: _applyEdit,
        onResetEdit: _resetEdit,
      ),
    );
  }
}

/// Parsed row out of the `ext.rune.inspect` payload.
class _ViewPayload {
  const _ViewPayload({
    required this.id,
    required this.source,
    required this.originalSource,
    required this.overridden,
    required this.data,
    required this.cacheSize,
    required this.lastError,
    required this.snapshotError,
  });

  factory _ViewPayload.fromJson(Map<String, Object?> json) {
    final idRaw = json['id'];
    return _ViewPayload(
      id: idRaw is int ? idRaw : int.tryParse('$idRaw') ?? -1,
      source: (json['source'] as String?) ?? '',
      originalSource: json['originalSource'] as String?,
      overridden: (json['overridden'] as bool?) ?? false,
      data: json['data'] is Map
          ? Map<String, Object?>.from(json['data']! as Map)
          : const <String, Object?>{},
      cacheSize: (json['cacheSize'] as num?)?.toInt(),
      lastError: json['lastError'] as String?,
      snapshotError: json['snapshotError'] as String?,
    );
  }

  final int id;
  final String source;
  final String? originalSource;
  final bool overridden;
  final Map<String, Object?> data;
  final int? cacheSize;
  final String? lastError;
  final String? snapshotError;
}

class _ViewCard extends StatefulWidget {
  const _ViewCard({
    required this.view,
    required this.onApplyEdit,
    required this.onResetEdit,
  });

  final _ViewPayload view;
  final Future<void> Function(int id, String source) onApplyEdit;
  final Future<void> Function(int id) onResetEdit;

  @override
  State<_ViewCard> createState() => _ViewCardState();
}

class _ViewCardState extends State<_ViewCard> {
  bool _editing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.view.source);
  }

  @override
  void didUpdateWidget(covariant _ViewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.view.source != widget.view.source) {
      _controller.text = widget.view.source;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final view = widget.view;
    final hasError = view.lastError != null || view.snapshotError != null;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(
          hasError
              ? Icons.error_outline
              : view.overridden
                  ? Icons.edit_note
                  : Icons.widgets_outlined,
          color: hasError ? theme.colorScheme.error : null,
        ),
        title: Row(
          children: [
            Text('RuneView #${view.id}'),
            if (view.overridden) ...[
              const SizedBox(width: 8),
              Chip(
                label: const Text('overridden'),
                visualDensity: VisualDensity.compact,
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
            ],
          ],
        ),
        subtitle: Text(
          view.source.split('\n').first.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Source',
            trailing: _editing
                ? null
                : TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _editing = true;
                        _controller.text = view.source;
                      });
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
            child: _editing
                ? _SourceEditor(
                    controller: _controller,
                    onCancel: () => setState(() => _editing = false),
                    onApply: () async {
                      final next = _controller.text;
                      setState(() => _editing = false);
                      await widget.onApplyEdit(view.id, next);
                    },
                  )
                : SelectableText(
                    view.source,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
          ),
          if (view.overridden && view.originalSource != null) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Original (pre-override)',
              trailing: TextButton.icon(
                onPressed: () => widget.onResetEdit(view.id),
                icon: const Icon(Icons.restart_alt, size: 16),
                label: const Text('Reset'),
              ),
              child: SelectableText(
                view.originalSource!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.disabledColor,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _Section(
            title: 'Data context',
            child: SelectableText(
              view.data.isEmpty
                  ? '(empty)'
                  : const JsonEncoder.withIndent('  ').convert(view.data),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
          if (view.cacheSize != null) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Parse cache',
              child: Text('${view.cacheSize} entries'),
            ),
          ],
          if (view.lastError != null) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Last render error',
              titleColor: theme.colorScheme.error,
              child: SelectableText(
                view.lastError!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          if (view.snapshotError != null) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Snapshot builder error',
              titleColor: theme.colorScheme.error,
              child: SelectableText(
                view.snapshotError!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceEditor extends StatelessWidget {
  const _SourceEditor({
    required this.controller,
    required this.onCancel,
    required this.onApply,
  });

  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          maxLines: null,
          minLines: 6,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Apply'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.titleColor,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Color? titleColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      color: titleColor,
                    ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _EmptyPane extends StatelessWidget {
  const _EmptyPane();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.widgets_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'No live RuneViews',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Mount a RuneView in the host app, then tap Refresh.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not reach the host process',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
