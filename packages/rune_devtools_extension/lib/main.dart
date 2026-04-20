import 'dart:convert';

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

/// Entry point of the Flutter web app that renders inside the
/// DevTools "rune" tab.
///
/// DevTools loads the compiled output of this app from
/// `extension/devtools/build/` at debug time. The app:
///
/// 1. Calls `ext.rune.inspect` on the host isolate over the VM
///    service.
/// 2. Parses the returned JSON into a `List<_ViewPayload>`.
/// 3. Renders one expandable card per live view surfacing the
///    source string, data context, parse-cache size, and last
///    error.
///
/// Refresh is manual for v0.1.0: tap the "Refresh" app-bar button
/// to re-query the host. Later versions can subscribe to a host
/// event stream once the main `rune` package grows one.
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
    if (_loading) {
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
      itemBuilder: (_, i) => _ViewCard(view: _views[i]),
    );
  }
}

/// Parsed row out of the `ext.rune.inspect` payload.
class _ViewPayload {
  const _ViewPayload({
    required this.id,
    required this.source,
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
  final Map<String, Object?> data;
  final int? cacheSize;
  final String? lastError;
  final String? snapshotError;
}

class _ViewCard extends StatelessWidget {
  const _ViewCard({required this.view});

  final _ViewPayload view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = view.lastError != null || view.snapshotError != null;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(
          hasError ? Icons.error_outline : Icons.widgets_outlined,
          color: hasError ? theme.colorScheme.error : null,
        ),
        title: Text('RuneView #${view.id}'),
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
            child: SelectableText(
              view.source,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
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

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.titleColor,
  });

  final String title;
  final Widget child;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                color: titleColor,
              ),
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
