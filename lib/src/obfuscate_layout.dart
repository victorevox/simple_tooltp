// import 'package:flutter/widgets.dart';

// import 'obfucate_tooltip_item.dart';

// class ObfuscateTooltipLayout extends StatefulWidget {
//   final Widget child;
//   ObfuscateTooltipLayout({
//     Key key,
//     @required this.child,
//   }) : super(key: key);

//   static _ObfuscateTooltipLayoutData of(BuildContext context) {
//     // return context.findAncestorWidgetOfExactType<ObfuscateTooltipLayout>();
//     return _ObfuscateTooltipLayoutData.of(context);
//   }

//   @override
//   ObfuscateTooltipLayoutState createState() => ObfuscateTooltipLayoutState();
// }

// class ObfuscateTooltipLayoutState extends State<ObfuscateTooltipLayout> {
//   List<ObfuscateTooltipItemState> _obfuscateItems = [];

//   List<ObfuscateTooltipItemState> get obfuscateItems => List<ObfuscateTooltipItemState>.unmodifiable(_obfuscateItems);

//   @override
//   Widget build(BuildContext context) {
//     return _ObfuscateTooltipLayoutData(
//       child: widget.child,
//       // obfuscateItems: obfuscateItems,
//       state: this,
//     );
//   }

//   // addItem(ObfuscateTooltipItemState item) {
//   //   _obfuscateItems.add(item);
//   // }

//   // removeItem(ObfuscateTooltipItemState item) {
//   //   _obfuscateItems.remove(item);
//   // }
// }

// class _ObfuscateTooltipLayoutData extends InheritedWidget {
//   // List<ObfuscateTooltipItem> obfuscateItems;
//   final ObfuscateTooltipLayoutState state;

//   _ObfuscateTooltipLayoutData({
//     Key key,
//     // @required this.obfuscateItems,
//     @required this.state,
//     @required this.child,
//   }) : super(key: key, child: child);

//   final Widget child;

//   static _ObfuscateTooltipLayoutData of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<_ObfuscateTooltipLayoutData>();
//   }

//   @override
//   bool updateShouldNotify(_ObfuscateTooltipLayoutData oldWidget) {
//     return true;
//   }
// }
