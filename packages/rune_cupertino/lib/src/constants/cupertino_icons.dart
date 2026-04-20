import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Seeds [registry] with a curated subset (30 entries) of Flutter's
/// [CupertinoIcons] constants, suitable for the stock `Icon(...)`
/// builder already shipped by rune. Consumers can register additional
/// icons on `RuneConfig.constants` directly; this seed covers the most
/// frequently used names on iOS surfaces.
void registerCupertinoIcons(ConstantRegistry registry) {
  registry.registerAll('CupertinoIcons', const <String, Object?>{
    'left_chevron': CupertinoIcons.left_chevron,
    'right_chevron': CupertinoIcons.right_chevron,
    'back': CupertinoIcons.back,
    'forward': CupertinoIcons.forward,
    'chevron_up': CupertinoIcons.chevron_up,
    'chevron_down': CupertinoIcons.chevron_down,
    'add': CupertinoIcons.add,
    'minus': CupertinoIcons.minus,
    'plus': CupertinoIcons.plus,
    'xmark': CupertinoIcons.xmark,
    'check_mark': CupertinoIcons.check_mark,
    'home': CupertinoIcons.home,
    'house': CupertinoIcons.house,
    'person': CupertinoIcons.person,
    'settings': CupertinoIcons.settings,
    'gear': CupertinoIcons.gear,
    'heart': CupertinoIcons.heart,
    'star': CupertinoIcons.star,
    'star_fill': CupertinoIcons.star_fill,
    'search': CupertinoIcons.search,
    'trash': CupertinoIcons.trash,
    'delete': CupertinoIcons.delete,
    'pencil': CupertinoIcons.pencil,
    'share': CupertinoIcons.share,
    'info': CupertinoIcons.info,
    'bell': CupertinoIcons.bell,
    'phone': CupertinoIcons.phone,
    'mail': CupertinoIcons.mail,
    'calendar': CupertinoIcons.calendar,
    'clock': CupertinoIcons.clock,
  });
}
