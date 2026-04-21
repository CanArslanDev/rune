#!/usr/bin/env dart
// CLI wrapper over `formatRuneSource` from `package:rune`.
//
// Usage:
//
//   # Format a file in place
//   dart run rune_test:rune_format path/to/source.rune --write
//
//   # Format from stdin, print to stdout
//   cat source.rune | dart run rune_test:rune_format -
//
//   # Check (exit non-zero if re-formatting would change output)
//   dart run rune_test:rune_format path/to/source.rune --check
//
// Flags:
//   --write, -w    Rewrite the input file in place. Mutually
//                  exclusive with --check.
//   --check, -c    Exit 1 if formatting would change the file;
//                  exit 0 otherwise. No output written.
//   --line-length  Override the fits-vs-break threshold
//                  (default 80).

import 'dart:io';

import 'package:rune/rune.dart';

const _usage = '''
Usage: rune_format [options] <path | ->

Formats a Rune source file (the same subset of Dart expression
syntax `RuneView.source` accepts). Pass `-` to read from stdin.

Options:
  -w, --write         Rewrite the input file in place.
  -c, --check         Exit 1 if formatting would change the file.
      --line-length   Max line length before breaking (default 80).
  -h, --help          Show this help.
''';

void main(List<String> argv) {
  if (argv.contains('-h') || argv.contains('--help')) {
    stdout.writeln(_usage);
    return;
  }

  var write = false;
  var check = false;
  var lineLength = 80;
  final positional = <String>[];

  for (var i = 0; i < argv.length; i++) {
    final arg = argv[i];
    switch (arg) {
      case '-w':
      case '--write':
        write = true;
      case '-c':
      case '--check':
        check = true;
      case '--line-length':
        if (i + 1 >= argv.length) {
          _die('--line-length requires an integer argument.');
        }
        final next = argv[++i];
        final parsed = int.tryParse(next);
        if (parsed == null || parsed < 20) {
          _die('--line-length must be an integer >= 20; got "$next".');
        }
        lineLength = parsed;
      default:
        if (arg.startsWith('-') && arg != '-') {
          _die('Unknown option: $arg\n$_usage');
        }
        positional.add(arg);
    }
  }

  if (write && check) {
    _die('--write and --check are mutually exclusive.');
  }
  if (positional.isEmpty) {
    _die('Missing input path (or `-` for stdin).\n$_usage');
  }
  if (positional.length > 1) {
    _die('Expected a single path; got ${positional.length}.');
  }

  final target = positional.single;
  final input = target == '-' ? stdin.readByteStreamSync() : File(target);
  final content = input is File
      ? input.readAsStringSync()
      : (input as String);

  final formatted = formatRuneSource(content, maxLineLength: lineLength);

  if (check) {
    if (formatted.trim() == content.trim()) {
      exit(0);
    } else {
      stderr.writeln('rune_format: "$target" is not formatted.');
      exit(1);
    }
  }

  if (write && target != '-') {
    File(target).writeAsStringSync(formatted);
    return;
  }

  stdout.write(formatted);
}

Never _die(String message) {
  stderr.writeln(message);
  exit(64); // EX_USAGE
}

extension on Stdin {
  String readByteStreamSync() {
    final buffer = StringBuffer();
    var line = readLineSync();
    while (line != null) {
      buffer.writeln(line);
      line = readLineSync();
    }
    return buffer.toString();
  }
}
