import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/defaults/rune_defaults.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

void main() {
  group('RuneDefaults', () {
    test('registerWidgets seeds the full Phase 1-2d widget set', () {
      final r = WidgetRegistry();
      RuneDefaults.registerWidgets(r);
      for (final name in const [
        'Text',
        'SizedBox',
        'Container',
        'Column',
        'Row',
        'Padding',
        'Center',
        'Stack',
        'Expanded',
        'Flexible',
        'Card',
        'Icon',
        'ListView',
        'AppBar',
        'Scaffold',
        'ElevatedButton',
        'TextButton',
        'IconButton',
        'FilledButton',
        'OutlinedButton',
        'SegmentedButton',
        'SearchBar',
        'TextField',
        'Switch',
        'Checkbox',
        'Form',
        'TextFormField',
        'Focus',
        'FocusScope',
        'Slider',
        'Radio',
        'CheckboxListTile',
        'SwitchListTile',
        'RadioListTile',
        'ListTile',
        'Divider',
        'Spacer',
        'GestureDetector',
        'InkWell',
        'SingleChildScrollView',
        'Wrap',
        'AspectRatio',
        'Positioned',
        'AnimatedContainer',
        'AnimatedOpacity',
        'AnimatedPositioned',
        'Hero',
        'AnimatedSwitcher',
        'AnimatedCrossFade',
        'AnimatedSize',
        'BottomNavigationBar',
        'NavigationBar',
        'NavigationRail',
        'TabBar',
        'Tab',
        'DropdownButton',
        'DropdownMenuItem',
        'FloatingActionButton',
        'Chip',
        'ChoiceChip',
        'FilterChip',
        'Badge',
        'CircularProgressIndicator',
        'LinearProgressIndicator',
        'Drawer',
        'SafeArea',
        'Visibility',
        'Opacity',
        'ClipRRect',
        'ClipOval',
        'Tooltip',
        'CustomScrollView',
        'SliverList',
        'SliverToBoxAdapter',
        'SliverAppBar',
        'SliverPadding',
        'SliverFillRemaining',
        'FittedBox',
        'ColoredBox',
        'DecoratedBox',
        'Offstage',
        'Semantics',
        'ConstrainedBox',
        'LimitedBox',
        'UnconstrainedBox',
        'FractionallySizedBox',
        'StatefulBuilder',
        'FutureBuilder',
        'StreamBuilder',
        'LayoutBuilder',
        'OrientationBuilder',
        'AlertDialog',
        'SimpleDialog',
        'SimpleDialogOption',
        'Dialog',
        'PopupMenuButton',
        'PopupMenuItem',
        'PopupMenuDivider',
        'RuneCompose',
        'Draggable',
        'LongPressDraggable',
        'DragTarget',
        'Dismissible',
        'InteractiveViewer',
        'ReorderableListView',
      ]) {
        expect(r.contains(name), isTrue, reason: 'missing widget $name');
      }
    });

    test('registerValues seeds the full Phase 1-2c value set', () {
      final r = ValueRegistry();
      RuneDefaults.registerValues(r);
      for (final key in const [
        'EdgeInsets.all',
        'EdgeInsets.symmetric',
        'EdgeInsets.only',
        'EdgeInsets.fromLTRB',
        'Color',
        'TextStyle',
        'BorderRadius.circular',
        'BoxDecoration',
        'Image.network',
        'Image.asset',
        'Duration',
        'DateTime',
        'TimeOfDay',
        'ColorScheme.fromSeed',
        'ThemeData',
        'ButtonSegment',
        'SearchAnchor.bar',
        'BottomNavigationBarItem',
        'NavigationDestination',
        'NavigationRailDestination',
        'GridView.count',
        'GridView.extent',
        'ListView.builder',
        'GridView.countBuilder',
        'GridView.extentBuilder',
        'SliverGrid.count',
        'SliverGrid.extent',
        'SliverList.builder',
        'SliverGrid.countBuilder',
        'SliverGrid.extentBuilder',
        'Transform.scale',
        'Transform.rotate',
        'Offset',
        'Transform.translate',
        'Transform.flip',
        'BoxConstraints',
        'RuneComponent',
        'TextEditingController',
        'ScrollController',
        'FocusNode',
        'PageController',
        'SnackBar',
        'MaterialPageRoute',
        'CupertinoPageRoute',
        'RouteSettings',
        'ValueKey',
      ]) {
        expect(r.contains(key), isTrue, reason: 'missing value $key');
      }
    });

    test('registerConstants seeds Phase 2a + Phase 2c icons', () {
      final r = ConstantRegistry();
      RuneDefaults.registerConstants(r);
      expect(r.contains('Colors', 'red'), isTrue);
      expect(r.contains('MainAxisAlignment', 'center'), isTrue);
      expect(r.contains('FlexFit', 'tight'), isTrue);
      expect(r.contains('BoxShape', 'circle'), isTrue);
      expect(r.contains('Icons', 'home'), isTrue);
      expect(r.contains('SnackBarBehavior', 'fixed'), isTrue);
      expect(r.contains('SnackBarBehavior', 'floating'), isTrue);
      expect(r.contains('ThemeMode', 'light'), isTrue);
      expect(r.contains('Brightness', 'dark'), isTrue);
      expect(r.contains('MaterialTapTargetSize', 'padded'), isTrue);
      expect(r.contains('AutovalidateMode', 'always'), isTrue);
      expect(r.contains('AutovalidateMode', 'onUserInteraction'), isTrue);
      expect(r.contains('DismissDirection', 'horizontal'), isTrue);
      expect(r.contains('DismissDirection', 'endToStart'), isTrue);
    });

    test('individual register* calls combined produce the full set', () {
      final w = WidgetRegistry();
      final v = ValueRegistry();
      final c = ConstantRegistry();
      RuneDefaults.registerWidgets(w);
      RuneDefaults.registerValues(v);
      RuneDefaults.registerConstants(c);
      expect(w.size, greaterThanOrEqualTo(105));
      expect(v.size, greaterThanOrEqualTo(45));
      expect(c.size, greaterThanOrEqualTo(55));
    });
  });
}
