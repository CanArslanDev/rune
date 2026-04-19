import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_scope.dart';

void main() {
  group('RuneScope - top-level scope', () {
    test('declare + lookup returns the declared value', () {
      final scope = RuneScope()..declare('x', 42);
      expect(scope.lookup('x'), 42);
      expect(scope.has('x'), isTrue);
    });

    test('lookup of an undeclared name returns null', () {
      final scope = RuneScope();
      expect(scope.lookup('missing'), isNull);
      expect(scope.has('missing'), isFalse);
    });

    test('declare followed by declare of the same name throws StateError', () {
      final scope = RuneScope()..declare('x', 1);
      expect(() => scope.declare('x', 2), throwsStateError);
    });

    test('declare + assign + lookup returns the reassigned value', () {
      final scope = RuneScope()
        ..declare('x', 1)
        ..assign('x', 99);
      expect(scope.lookup('x'), 99);
    });

    test('assign to an undeclared name throws BindingException', () {
      final scope = RuneScope();
      try {
        scope.assign('undeclared', 1);
        fail('expected BindingException');
      } on BindingException catch (e) {
        expect(e.message, contains('undeclared'));
        expect(e.message, contains('undeclared'));
      }
    });

    test('declare(x, null) followed by has(x) returns true', () {
      // Distinguishes "declared as null" from "not declared".
      final scope = RuneScope()..declare('x', null);
      expect(scope.has('x'), isTrue);
      expect(scope.lookup('x'), isNull);
    });
  });

  group('RuneScope - nested (child) scopes', () {
    test('child scope inherits parent declarations via lookup', () {
      final parent = RuneScope()..declare('outer', 'p');
      final child = RuneScope.child(parent);
      expect(child.lookup('outer'), 'p');
      expect(child.has('outer'), isTrue);
    });

    test("child's own declaration shadows parent's with the same name", () {
      final parent = RuneScope()..declare('x', 'parent');
      final child = RuneScope.child(parent)..declare('x', 'child');
      expect(child.lookup('x'), 'child');
      expect(parent.lookup('x'), 'parent');
    });

    test('assign in child to a name declared in parent writes to parent', () {
      final parent = RuneScope()..declare('x', 'old');
      final child = RuneScope.child(parent)..assign('x', 'new');
      expect(parent.lookup('x'), 'new');
      expect(child.lookup('x'), 'new');
    });

    test(
        'assign in child to a parent-only name does not declare it locally '
        '(second child of same parent still sees the update)', () {
      final parent = RuneScope()..declare('x', 'old');
      final child1 = RuneScope.child(parent)..assign('x', 'new');
      // Nothing declared in child1 itself.
      expect(child1.has('x'), isTrue); // true via parent chain
      // A sibling child created afterwards sees the parent-written value.
      final child2 = RuneScope.child(parent);
      expect(child2.lookup('x'), 'new');
    });

    test('nested child assign writes to grandparent when declared there', () {
      final gp = RuneScope()..declare('g', 1);
      final p = RuneScope.child(gp);
      final c = RuneScope.child(p)..assign('g', 2);
      expect(gp.lookup('g'), 2);
      expect(p.lookup('g'), 2);
      expect(c.lookup('g'), 2);
    });

    test('assign in a child to a name declared nowhere throws', () {
      final parent = RuneScope();
      final child = RuneScope.child(parent);
      expect(
        () => child.assign('ghost', 1),
        throwsA(isA<BindingException>()),
      );
    });
  });
}
