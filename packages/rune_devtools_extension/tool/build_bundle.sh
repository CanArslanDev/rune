#!/usr/bin/env bash
# Build the DevTools extension's Flutter web bundle into
# extension/devtools/build/. Run this before `dart pub publish` and
# before relying on the extension from a path-dependency during
# local development (Flutter DevTools needs the compiled bundle to
# render the "rune" tab).
#
# The output is deliberately gitignored: it is ~30 MB of derived
# artefacts that would bloat history. pub.dev publishes the bundle
# inside the package archive on each release.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$PACKAGE_DIR/extension/devtools/build"

cd "$PACKAGE_DIR"

echo "-> flutter pub get"
flutter pub get

echo "-> flutter build web (output: $OUTPUT_DIR)"
rm -rf "$OUTPUT_DIR"
flutter build web --pwa-strategy=none --output="$OUTPUT_DIR"

echo "-> stripping .symbols debug sidecars (~6 MB saved)"
find "$OUTPUT_DIR" -name '*.symbols' -delete

SIZE=$(du -sh "$OUTPUT_DIR" | cut -f1)
echo "-> done. Bundle size: $SIZE"
