import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/defaults/phase_2a_constants.dart';
import 'package:rune/src/registry/constant_registry.dart';

void main() {
  group('registerPhase2aConstants', () {
    test('seeds a handful of Colors', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('Colors', 'red'), Colors.red);
      expect(r.resolve('Colors', 'blue'), Colors.blue);
      expect(r.resolve('Colors', 'transparent'), Colors.transparent);
      expect(r.resolve('Colors', 'white'), Colors.white);
      expect(r.resolve('Colors', 'black'), Colors.black);
    });

    test('seeds MainAxisAlignment', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('MainAxisAlignment', 'start'),
          MainAxisAlignment.start,);
      expect(r.resolve('MainAxisAlignment', 'center'),
          MainAxisAlignment.center,);
      expect(r.resolve('MainAxisAlignment', 'end'),
          MainAxisAlignment.end,);
      expect(r.resolve('MainAxisAlignment', 'spaceBetween'),
          MainAxisAlignment.spaceBetween,);
      expect(r.resolve('MainAxisAlignment', 'spaceAround'),
          MainAxisAlignment.spaceAround,);
      expect(r.resolve('MainAxisAlignment', 'spaceEvenly'),
          MainAxisAlignment.spaceEvenly,);
    });

    test('seeds CrossAxisAlignment + MainAxisSize', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('CrossAxisAlignment', 'start'),
          CrossAxisAlignment.start,);
      expect(r.resolve('CrossAxisAlignment', 'stretch'),
          CrossAxisAlignment.stretch,);
      expect(r.resolve('MainAxisSize', 'max'), MainAxisSize.max);
      expect(r.resolve('MainAxisSize', 'min'), MainAxisSize.min);
    });

    test('seeds TextAlign and TextOverflow', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('TextAlign', 'left'), TextAlign.left);
      expect(r.resolve('TextAlign', 'center'), TextAlign.center);
      expect(r.resolve('TextOverflow', 'ellipsis'), TextOverflow.ellipsis);
      expect(r.resolve('TextOverflow', 'fade'), TextOverflow.fade);
    });

    test('seeds Alignment singletons', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('Alignment', 'topLeft'), Alignment.topLeft);
      expect(r.resolve('Alignment', 'center'), Alignment.center);
      expect(r.resolve('Alignment', 'bottomRight'), Alignment.bottomRight);
    });

    test('seeds BoxFit + StackFit + Axis', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('BoxFit', 'cover'), BoxFit.cover);
      expect(r.resolve('BoxFit', 'contain'), BoxFit.contain);
      expect(r.resolve('StackFit', 'expand'), StackFit.expand);
      expect(r.resolve('Axis', 'horizontal'), Axis.horizontal);
      expect(r.resolve('Axis', 'vertical'), Axis.vertical);
    });

    test('seeds FontWeight', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('FontWeight', 'normal'), FontWeight.normal);
      expect(r.resolve('FontWeight', 'bold'), FontWeight.bold);
      expect(r.resolve('FontWeight', 'w400'), FontWeight.w400);
      expect(r.resolve('FontWeight', 'w700'), FontWeight.w700);
    });

    test('seeds EdgeInsets.zero', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('EdgeInsets', 'zero'), EdgeInsets.zero);
    });

    test('register twice over the same registry throws', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(() => registerPhase2aConstants(r), throwsStateError);
    });

    test('seeds BoxShape', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('BoxShape', 'rectangle'), BoxShape.rectangle);
      expect(r.resolve('BoxShape', 'circle'), BoxShape.circle);
    });

    test('seeds FlexFit', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('FlexFit', 'tight'), FlexFit.tight);
      expect(r.resolve('FlexFit', 'loose'), FlexFit.loose);
    });

    test('seeds WrapAlignment', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('WrapAlignment', 'start'), WrapAlignment.start);
      expect(r.resolve('WrapAlignment', 'center'), WrapAlignment.center);
      expect(
        r.resolve('WrapAlignment', 'spaceBetween'),
        WrapAlignment.spaceBetween,
      );
    });

    test('seeds WrapCrossAlignment', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(
        r.resolve('WrapCrossAlignment', 'center'),
        WrapCrossAlignment.center,
      );
      expect(
        r.resolve('WrapCrossAlignment', 'start'),
        WrapCrossAlignment.start,
      );
    });

    test('seeds Curves', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('Curves', 'linear'), same(Curves.linear));
      expect(r.resolve('Curves', 'easeIn'), same(Curves.easeIn));
      expect(r.resolve('Curves', 'easeOut'), same(Curves.easeOut));
      expect(r.resolve('Curves', 'easeInOut'), same(Curves.easeInOut));
      expect(r.resolve('Curves', 'bounceIn'), same(Curves.bounceIn));
      expect(r.resolve('Curves', 'bounceOut'), same(Curves.bounceOut));
      expect(r.resolve('Curves', 'elasticIn'), same(Curves.elasticIn));
      expect(r.resolve('Curves', 'elasticOut'), same(Curves.elasticOut));
      expect(r.resolve('Curves', 'fastOutSlowIn'), same(Curves.fastOutSlowIn));
    });

    test('seeds BottomNavigationBarType', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(
        r.resolve('BottomNavigationBarType', 'fixed'),
        BottomNavigationBarType.fixed,
      );
      expect(
        r.resolve('BottomNavigationBarType', 'shifting'),
        BottomNavigationBarType.shifting,
      );
    });

    test('seeds CrossFadeState', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(
        r.resolve('CrossFadeState', 'showFirst'),
        CrossFadeState.showFirst,
      );
      expect(
        r.resolve('CrossFadeState', 'showSecond'),
        CrossFadeState.showSecond,
      );
    });

    test('seeds Clip', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(r.resolve('Clip', 'antiAlias'), Clip.antiAlias);
    });

    test('seeds DecorationPosition', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(
        r.resolve('DecorationPosition', 'background'),
        DecorationPosition.background,
      );
      expect(
        r.resolve('DecorationPosition', 'foreground'),
        DecorationPosition.foreground,
      );
    });

    test('seeds ListTileControlAffinity', () {
      final r = ConstantRegistry();
      registerPhase2aConstants(r);
      expect(
        r.resolve('ListTileControlAffinity', 'leading'),
        ListTileControlAffinity.leading,
      );
      expect(
        r.resolve('ListTileControlAffinity', 'trailing'),
        ListTileControlAffinity.trailing,
      );
      expect(
        r.resolve('ListTileControlAffinity', 'platform'),
        ListTileControlAffinity.platform,
      );
    });
  });
}
