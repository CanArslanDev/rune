# DevTools extension

`rune_devtools_extension` is a Flutter DevTools tab that inspects every live `RuneView` in your host app while you debug. It shows:

- Each view's source string (selectable, monospace).
- Its data context, pretty-printed as JSON.
- Parse-cache size (how many distinct source strings have been parsed through it).
- Last render error, if the view is currently showing the fallback widget.

It never modifies anything; v0.1.0 is read-only.

## How it fits together

Two packages work in tandem:

1. **`rune`** (>= v1.18.0) registers a VM service extension named `ext.rune.inspect` the first time any `RuneView` mounts. This uses `dart:developer.registerExtension`, which is compiled out in release builds, so the feature is zero-cost for production apps.

2. **`rune_devtools_extension`** is a Flutter web app loaded by Flutter DevTools into a tab iframe. When you tap "Refresh", the tab calls `ext.rune.inspect` over the VM service protocol, parses the returned JSON, and renders one expandable card per live view.

## Install

Add the extension as a **dev dependency** of your host app:

```yaml
dev_dependencies:
  rune_devtools_extension: ^0.1.0
```

Then:

```bash
flutter pub get
```

No runtime code lands in your release build. DevTools auto-discovers the extension on the next `flutter run`.

## Using the extension

1. Run your host app in **debug** or **profile** mode:

    ```bash
    flutter run -d <device>
    ```

    Release builds strip `dart:developer.registerExtension`, so the tab cannot talk to them.

2. Open Flutter DevTools. The tab shows up as **rune** alongside the standard tabs (Inspector, Memory, Performance, etc.).

3. Mount at least one `RuneView` in your app. The tab is empty until the host has a view to introspect because `ext.rune.inspect` is registered lazily on the first mount.

4. Tap **Refresh** on the tab's toolbar. Each live `RuneView` appears as an expandable card. Tap to see the source, data, cache, and last error.

## What the payload looks like

Internally the tab receives a JSON document shaped like:

```json
{
  "views": [
    {
      "id": 0,
      "source": "Text('hello')",
      "data": {"name": "Ali"},
      "cacheSize": 1,
      "lastError": null
    },
    {
      "id": 1,
      "source": "NotAWidget()",
      "data": {},
      "cacheSize": 0,
      "lastError": "UnregisteredBuilderException: ..."
    }
  ]
}
```

You can call the endpoint directly (without the tab) from any VM-service client. Flutter DevTools' "Evaluate expression" console or the `dart devtools` CLI can send the request. Useful when you want to script introspection or capture snapshots in a test run.

## Troubleshooting

**"Could not reach the host process"**
The host has no `RuneView` mounted yet (the service extension is lazy). Mount one and tap Refresh again. If the host is in release mode, the extension cannot fire.

**The tab does not appear in DevTools**
- Confirm `rune_devtools_extension` is listed under `dev_dependencies` (not `dependencies`).
- Run `flutter pub get` after adding it.
- Restart the DevTools window (fully close the browser tab and reopen from `flutter run` output).

**The tab shows stale data**
Tap Refresh. v0.1.0 is pull-based; auto-refresh on `notifyListeners` is planned for a later version.

## On mobile

The extension works when running the host on a real iOS or Android device in debug mode. Flutter tooling forwards the device's VM service to the developer machine, and DevTools (running in a browser on the developer machine) talks to it over the forwarded port. The extension UI never runs on-device; it runs inside the DevTools browser tab.

## See also

- [Source of `ext.rune.inspect`](../lib/src/binding/rune_inspector.dart) in the main `rune` package.
- [Source of the extension UI](../packages/rune_devtools_extension/lib/main.dart).
- [DevTools extensions documentation](https://docs.flutter.dev/tools/devtools/extensions) from the Flutter team.
