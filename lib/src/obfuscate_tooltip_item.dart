import 'dart:async';

import 'package:flutter/material.dart';

import 'package:simple_tooltip/simple_tooltip.dart';

class ObfuscateTooltipItem extends StatefulWidget {
  /// This is just needed when the `ObfuscateTooltipItem` is placed outside the context
  /// of `ObfuscateTooltipLayoutState`, ie: In a modal route or an OverlayLayout
  final List<GlobalKey<SimpleTooltipState>> tooltipKeys;

  final Widget child;

  const ObfuscateTooltipItem({
    Key? key,
    required this.tooltipKeys,
    required this.child,
  }) : super(key: key);

  @override
  ObfuscateTooltipItemState createState() => ObfuscateTooltipItemState();
}

class ObfuscateTooltipItemState extends State<ObfuscateTooltipItem> with WidgetsBindingObserver {
  // LayerLink _layerLink = LayerLink();
  GlobalKey _key = GlobalKey();

  late StreamSubscription _intervalSubscription;
  _PositionAndSize? _lastPositionSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _intervalSubscription = Stream.periodic(Duration(seconds: 1)).listen((event) {
      final currentPositionSize = getPositionAndSize();
      if (_lastPositionSize != currentPositionSize) {
        // print("Notifying change");
        _notifySizeChange(widget.tooltipKeys);
      }
      _lastPositionSize = currentPositionSize;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _addToTooltips(widget.tooltipKeys);
    });
  }

  @override
  void didUpdateWidget(ObfuscateTooltipItem oldWidget) {
    if (oldWidget.tooltipKeys != widget.tooltipKeys) {
      _removeFromTooltips(oldWidget.tooltipKeys);
      _addToTooltips(widget.tooltipKeys);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intervalSubscription.cancel();
    _removeFromTooltips(widget.tooltipKeys);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _notifySizeChange(widget.tooltipKeys);
  }

  _notifySizeChange(List<GlobalKey<SimpleTooltipState>> keys) {
    if (keys.isNotEmpty) {
      for (var tooltipKey in keys) {
        tooltipKey.currentState?.doCheckForObfuscation();
      }
    }
  }

  _PositionAndSize? getPositionAndSize() {
    if (!mounted) return null;
    final RenderBox? renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    return _PositionAndSize(
      context: context,
      globalPosition: position,
      size: renderBox.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }

  _addToTooltips(List<GlobalKey<SimpleTooltipState>> keys) {
    if (keys.isNotEmpty) {
      for (var tooltipKey in keys) {
        tooltipKey.currentState?.addObfuscateItem(this);
      }
    }
  }

  _removeFromTooltips(List<GlobalKey<SimpleTooltipState>> keys) {
    if (keys.isNotEmpty) {
      for (var tooltipKey in keys) {
        tooltipKey.currentState?.removeObfuscatedItem(this);
      }
    }
  }
}

class _PositionAndSize {
  final BuildContext context;
  final Size size;
  final Offset globalPosition;
  _PositionAndSize({
    required this.context,
    required this.size,
    required this.globalPosition,
  });

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is _PositionAndSize && o.size == size && o.globalPosition == globalPosition;
  }

  @override
  int get hashCode => size.hashCode ^ globalPosition.hashCode;
}
