// test/architecture/import_flow_test.dart
//
// Walks lib/src/ and asserts no file imports "upward" in the layer
// hierarchy. Import lines are matched with a simple regex — no
// analyzer dependency here to keep the test fast.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _importLine = RegExp(
  r'''^\s*import\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

List<String> _dartFilesUnder(String rootPath) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    fail('Expected directory does not exist: $rootPath');
  }
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .map((f) => f.path)
      .toList(growable: false);
}

List<String> _importsOf(String filePath) {
  final source = File(filePath).readAsStringSync();
  return _importLine
      .allMatches(source)
      .map((m) => m.group(1)!)
      .toList(growable: false);
}

void _forbid(
  String layerName,
  List<String> layerFiles,
  List<String> forbiddenImportSubstrings,
) {
  for (final file in layerFiles) {
    final imports = _importsOf(file);
    for (final imp in imports) {
      for (final forbidden in forbiddenImportSubstrings) {
        expect(
          imp.contains(forbidden),
          isFalse,
          reason:
              '$layerName file $file illegally imports "$imp" '
              '(forbidden substring: "$forbidden")',
        );
      }
    }
  }
}

void main() {
  group('architecture — unidirectional import flow under lib/src/', () {
    test('src/binding/ is self-contained (no intra-package imports)', () {
      final files = _dartFilesUnder('lib/src/binding');
      for (final file in files) {
        final imports = _importsOf(file);
        for (final imp in imports) {
          expect(
            imp.startsWith('package:rune/src/'),
            isFalse,
            reason:
                'binding file $file imports $imp; binding must be '
                'self-contained',
          );
        }
      }
    });

    test('src/parser/ only imports from src/core/', () {
      _forbid(
        'parser',
        _dartFilesUnder('lib/src/parser'),
        const [
          'package:rune/src/binding/',
          'package:rune/src/builders/',
          'package:rune/src/registry/',
          'package:rune/src/resolver/',
          'package:rune/src/defaults/',
          'package:rune/src/config.dart',
          'package:rune/src/dynamic_view.dart',
        ],
      );
    });

    test(
      'src/registry/ does not import resolver/parser/defaults/config/view',
      () {
        _forbid(
          'registry',
          _dartFilesUnder('lib/src/registry'),
          const [
            'package:rune/src/parser/',
            'package:rune/src/resolver/',
            'package:rune/src/defaults/',
            'package:rune/src/config.dart',
            'package:rune/src/dynamic_view.dart',
          ],
        );
      },
    );

    test('src/resolver/ does not import defaults/config/dynamic_view', () {
      _forbid(
        'resolver',
        _dartFilesUnder('lib/src/resolver'),
        const [
          'package:rune/src/defaults/',
          'package:rune/src/config.dart',
          'package:rune/src/dynamic_view.dart',
        ],
      );
    });

    test('src/defaults/ does not import resolver or dynamic_view', () {
      _forbid(
        'defaults',
        _dartFilesUnder('lib/src/defaults'),
        const [
          'package:rune/src/resolver/',
          'package:rune/src/dynamic_view.dart',
        ],
      );
    });

    test(
      'src/builders/widgets/ and src/builders/values/ do not import '
      'resolver/registry/parser/defaults/config/dynamic_view',
      () {
        _forbid(
          'builders/widgets',
          _dartFilesUnder('lib/src/builders/widgets'),
          const [
            'package:rune/src/parser/',
            'package:rune/src/registry/',
            'package:rune/src/resolver/',
            'package:rune/src/defaults/',
            'package:rune/src/config.dart',
            'package:rune/src/dynamic_view.dart',
          ],
        );
        _forbid(
          'builders/values',
          _dartFilesUnder('lib/src/builders/values'),
          const [
            'package:rune/src/parser/',
            'package:rune/src/registry/',
            'package:rune/src/resolver/',
            'package:rune/src/defaults/',
            'package:rune/src/config.dart',
            'package:rune/src/dynamic_view.dart',
          ],
        );
      },
    );

    test(
      'src/builders/ root (excluding widgets/ and values/) may import '
      'src/resolver/rune_closure.dart only. No other resolver imports.',
      () {
        final rootFiles = _dartFilesUnder('lib/src/builders')
            .where(
              (path) =>
                  !path.contains('/builders/widgets/') &&
                  !path.contains('/builders/values/'),
            )
            .toList(growable: false);
        for (final file in rootFiles) {
          final imports = _importsOf(file);
          for (final imp in imports) {
            if (imp.startsWith('package:rune/src/resolver/')) {
              expect(
                imp,
                'package:rune/src/resolver/rune_closure.dart',
                reason:
                    'builders/ root file $file imports $imp; only '
                    'rune_closure.dart is allowed from the resolver '
                    'layer (shared closure value type).',
              );
            }
          }
          for (final forbidden in const [
            'package:rune/src/parser/',
            'package:rune/src/registry/',
            'package:rune/src/defaults/',
            'package:rune/src/config.dart',
            'package:rune/src/dynamic_view.dart',
          ]) {
            for (final imp in imports) {
              expect(
                imp.contains(forbidden),
                isFalse,
                reason:
                    'builders/ root file $file illegally imports "$imp" '
                    '(forbidden substring: "$forbidden")',
              );
            }
          }
        }
      },
    );

    test('src/bridges/ only imports config (not resolver/defaults/view)', () {
      _forbid(
        'bridges',
        _dartFilesUnder('lib/src/bridges'),
        const [
          'package:rune/src/parser/',
          'package:rune/src/resolver/',
          'package:rune/src/defaults/',
          'package:rune/src/dynamic_view.dart',
        ],
      );
    });

    test('src/dev/ only imports Flutter (no internal rune layers)', () {
      _forbid(
        'dev',
        _dartFilesUnder('lib/src/dev'),
        const [
          'package:rune/src/parser/',
          'package:rune/src/resolver/',
          'package:rune/src/registry/',
          'package:rune/src/builders/',
          'package:rune/src/core/',
          'package:rune/src/binding/',
          'package:rune/src/defaults/',
          'package:rune/src/bridges/',
          'package:rune/src/config.dart',
          'package:rune/src/dynamic_view.dart',
        ],
      );
    });

    test('src/config.dart does not import dynamic_view', () {
      _forbid(
        'config',
        const ['lib/src/config.dart'],
        const ['package:rune/src/dynamic_view.dart'],
      );
    });

    test(
      'nothing in lib/src/ (except the view itself) imports '
      'dynamic_view.dart',
      () {
        final all = _dartFilesUnder('lib/src');
        for (final file in all) {
          if (file.endsWith('dynamic_view.dart')) continue;
          final imports = _importsOf(file);
          for (final imp in imports) {
            expect(
              imp.contains('package:rune/src/dynamic_view.dart'),
              isFalse,
              reason: '$file illegally imports dynamic_view.dart',
            );
          }
        }
      },
    );
  });
}
