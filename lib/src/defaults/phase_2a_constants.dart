import 'package:flutter/material.dart';
import 'package:rune/src/registry/constant_registry.dart';

/// Seeds [registry] with the Phase-2a default constants:
/// - Every `Colors` member that is a plain `Color` value (including the
///   base tone of each `MaterialColor`, which is itself a `Color`).
/// - All enum values in: `MainAxisAlignment`, `CrossAxisAlignment`,
///   `MainAxisSize`, `TextAlign`, `BoxFit`, `StackFit`, `Axis`,
///   `TextOverflow`, `BoxShape`, `FlexFit`, `WrapAlignment`,
///   `WrapCrossAlignment`.
/// - The nine aligned-singleton `Alignment` values.
/// - The `FontWeight` weights `w100..w900`, `normal`, and `bold`.
/// - `EdgeInsets.zero`.
///
/// Calling this twice on the same registry throws `StateError` via the
/// underlying [ConstantRegistry.register] duplicate guard.
void registerPhase2aConstants(ConstantRegistry registry) {
  _registerColors(registry);
  _registerMainAxisAlignment(registry);
  _registerCrossAxisAlignment(registry);
  _registerMainAxisSize(registry);
  _registerTextAlign(registry);
  _registerTextOverflow(registry);
  _registerAlignment(registry);
  _registerBoxFit(registry);
  _registerStackFit(registry);
  _registerAxis(registry);
  _registerFontWeight(registry);
  _registerBoxShape(registry); // Phase 2b addition
  _registerFlexFit(registry);
  _registerWrapAlignment(registry);
  _registerWrapCrossAlignment(registry);
  _registerEdgeInsetsSingletons(registry);
}

// Registers every Colors member that is a concrete Color value.
void _registerColors(ConstantRegistry r) {
  r.registerAll('Colors', <String, Object?>{
    'transparent': Colors.transparent,
    'white': Colors.white,
    'white70': Colors.white70,
    'white60': Colors.white60,
    'white54': Colors.white54,
    'white38': Colors.white38,
    'white30': Colors.white30,
    'white24': Colors.white24,
    'white12': Colors.white12,
    'white10': Colors.white10,
    'black': Colors.black,
    'black87': Colors.black87,
    'black54': Colors.black54,
    'black45': Colors.black45,
    'black38': Colors.black38,
    'black26': Colors.black26,
    'black12': Colors.black12,
    'red': Colors.red,
    'redAccent': Colors.redAccent,
    'pink': Colors.pink,
    'pinkAccent': Colors.pinkAccent,
    'purple': Colors.purple,
    'purpleAccent': Colors.purpleAccent,
    'deepPurple': Colors.deepPurple,
    'deepPurpleAccent': Colors.deepPurpleAccent,
    'indigo': Colors.indigo,
    'indigoAccent': Colors.indigoAccent,
    'blue': Colors.blue,
    'blueAccent': Colors.blueAccent,
    'lightBlue': Colors.lightBlue,
    'lightBlueAccent': Colors.lightBlueAccent,
    'cyan': Colors.cyan,
    'cyanAccent': Colors.cyanAccent,
    'teal': Colors.teal,
    'tealAccent': Colors.tealAccent,
    'green': Colors.green,
    'greenAccent': Colors.greenAccent,
    'lightGreen': Colors.lightGreen,
    'lightGreenAccent': Colors.lightGreenAccent,
    'lime': Colors.lime,
    'limeAccent': Colors.limeAccent,
    'yellow': Colors.yellow,
    'yellowAccent': Colors.yellowAccent,
    'amber': Colors.amber,
    'amberAccent': Colors.amberAccent,
    'orange': Colors.orange,
    'orangeAccent': Colors.orangeAccent,
    'deepOrange': Colors.deepOrange,
    'deepOrangeAccent': Colors.deepOrangeAccent,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'blueGrey': Colors.blueGrey,
  });
}

// Registers all MainAxisAlignment enum values by name.
void _registerMainAxisAlignment(ConstantRegistry r) {
  r.registerAll('MainAxisAlignment', <String, Object?>{
    for (final v in MainAxisAlignment.values) v.name: v,
  });
}

// Registers all CrossAxisAlignment enum values by name.
void _registerCrossAxisAlignment(ConstantRegistry r) {
  r.registerAll('CrossAxisAlignment', <String, Object?>{
    for (final v in CrossAxisAlignment.values) v.name: v,
  });
}

// Registers all MainAxisSize enum values by name.
void _registerMainAxisSize(ConstantRegistry r) {
  r.registerAll('MainAxisSize', <String, Object?>{
    for (final v in MainAxisSize.values) v.name: v,
  });
}

// Registers all TextAlign enum values by name.
void _registerTextAlign(ConstantRegistry r) {
  r.registerAll('TextAlign', <String, Object?>{
    for (final v in TextAlign.values) v.name: v,
  });
}

// Registers all TextOverflow enum values by name.
void _registerTextOverflow(ConstantRegistry r) {
  r.registerAll('TextOverflow', <String, Object?>{
    for (final v in TextOverflow.values) v.name: v,
  });
}

// Registers the nine named Alignment singletons.
void _registerAlignment(ConstantRegistry r) {
  r.registerAll('Alignment', const <String, Object?>{
    'topLeft': Alignment.topLeft,
    'topCenter': Alignment.topCenter,
    'topRight': Alignment.topRight,
    'centerLeft': Alignment.centerLeft,
    'center': Alignment.center,
    'centerRight': Alignment.centerRight,
    'bottomLeft': Alignment.bottomLeft,
    'bottomCenter': Alignment.bottomCenter,
    'bottomRight': Alignment.bottomRight,
  });
}

// Registers all BoxFit enum values by name.
void _registerBoxFit(ConstantRegistry r) {
  r.registerAll('BoxFit', <String, Object?>{
    for (final v in BoxFit.values) v.name: v,
  });
}

// Registers all StackFit enum values by name.
void _registerStackFit(ConstantRegistry r) {
  r.registerAll('StackFit', <String, Object?>{
    for (final v in StackFit.values) v.name: v,
  });
}

// Registers all Axis enum values by name.
void _registerAxis(ConstantRegistry r) {
  r.registerAll('Axis', <String, Object?>{
    for (final v in Axis.values) v.name: v,
  });
}

// Registers FontWeight weights w100-w900, normal, and bold.
void _registerFontWeight(ConstantRegistry r) {
  r.registerAll('FontWeight', const <String, Object?>{
    'w100': FontWeight.w100,
    'w200': FontWeight.w200,
    'w300': FontWeight.w300,
    'w400': FontWeight.w400,
    'w500': FontWeight.w500,
    'w600': FontWeight.w600,
    'w700': FontWeight.w700,
    'w800': FontWeight.w800,
    'w900': FontWeight.w900,
    'normal': FontWeight.normal,
    'bold': FontWeight.bold,
  });
}

// Registers all BoxShape enum values by name.
void _registerBoxShape(ConstantRegistry r) {
  r.registerAll('BoxShape', <String, Object?>{
    for (final v in BoxShape.values) v.name: v,
  });
}

// Registers all FlexFit enum values by name.
void _registerFlexFit(ConstantRegistry r) {
  r.registerAll('FlexFit', <String, Object?>{
    for (final v in FlexFit.values) v.name: v,
  });
}

// Registers all WrapAlignment enum values by name.
void _registerWrapAlignment(ConstantRegistry r) {
  r.registerAll('WrapAlignment', <String, Object?>{
    for (final v in WrapAlignment.values) v.name: v,
  });
}

// Registers all WrapCrossAlignment enum values by name.
void _registerWrapCrossAlignment(ConstantRegistry r) {
  r.registerAll('WrapCrossAlignment', <String, Object?>{
    for (final v in WrapCrossAlignment.values) v.name: v,
  });
}

// Registers EdgeInsets.zero singleton.
void _registerEdgeInsetsSingletons(ConstantRegistry r) {
  r.register('EdgeInsets', 'zero', EdgeInsets.zero);
}
