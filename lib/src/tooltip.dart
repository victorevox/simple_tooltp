library tooltip;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'types.dart';

part 'balloon.dart';
part 'balloon_positioner.dart';

class SimpleTooltip extends StatefulWidget {
  final Widget child;
  final TooltipDirection tooltipDirection;
  final Widget content;
  final bool show;
  final Function onClose;
  final EdgeInsets ballonPadding;

  /// [top], [right], [bottom], [left] position the Tooltip absolute relative to the whole screen
  double top, right, bottom, left;

  /// [minWidth], [minHeight], [maxWidth], [maxHeight] optional size constraints.
  /// If a constraint is not set the size will ajust to the content
  double minWidth, minHeight, maxWidth, maxHeight;

  ///
  /// The distance of the tip of the arrow's tip to the center of the target
  final double arrowTipDistance;

  ///
  /// The length of the Arrow
  final double arrowLength;

  ///
  /// the stroke width of the border
  final double borderWidth;

  ///
  /// The minium padding from the Tooltip to the screen limits
  final double minimumOutSidePadding;

  ///
  /// The corder radii of the border
  final double borderRadius;

  ///
  /// The width of the arrow at its base
  final double arrowBaseWidth;

  ///
  /// The color of the border
  final Color borderColor;

  SimpleTooltip({
    Key key,
    this.child,
    this.tooltipDirection = TooltipDirection.up,
    this.content,
    this.show,
    this.onClose,
    this.ballonPadding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.maxWidth,
    this.minWidth,
    this.maxHeight,
    this.minHeight,
    this.arrowTipDistance = 2,
    this.arrowLength = 20,
    this.minimumOutSidePadding = 20.0,
    this.arrowBaseWidth = 20.0,
    this.borderRadius = 10,
    this.borderWidth = 2.0,
    this.borderColor = const Color(0xFF50FFFF),
  }) : super(key: key);

  @override
  _SimpleTooltipState createState() => _SimpleTooltipState();
}

class _SimpleTooltipState extends State<SimpleTooltip> {
  bool _displaying = false;

  final LayerLink layerLink = LayerLink();

  OverlayEntry overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.show) {
        _showTooltip();
      }
    });
  }

  @override
  void didUpdateWidget(SimpleTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hideTooltip();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.show) {
        _showTooltip();
      } else {
        _hideTooltip();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _hideTooltip();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: widget.child,
    );
  }

  void _showTooltip() {
    if (_displaying || !mounted) {
      return;
    }
    this.overlayEntry = this._buildOverlay();
    Overlay.of(context).insert(this.overlayEntry);
    this._displaying = true;
  }

  void _hideTooltip() {
    if (!_displaying) {
      return;
    }
    this.overlayEntry.remove();
    _displaying = false;
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (overlayContext) {
        return _BallonPositioner(
          link: layerLink,
          tooltipDirection: widget.tooltipDirection,
          maxHeight: widget.maxHeight,
          minHeight: widget.minHeight,
          maxWidth: widget.maxWidth,
          minWidth: widget.minWidth,
          child: _Ballon(
            content: widget.content,
            borderRadius: widget.borderRadius,
            arrowBaseWidth: widget.arrowBaseWidth,
            arrowLength: widget.arrowLength,
            arrowTipDistance: widget.arrowTipDistance,
            ballonPadding: widget.ballonPadding,
            borderColor: widget.borderColor,
            borderWidth: widget.borderWidth,
            tooltipDirection: widget.tooltipDirection,
            
          ),
          // arrowBaseWidth: widget.arrowBaseWidth,
          arrowLength: widget.arrowLength,
          arrowTipDistance: widget.arrowTipDistance,
          outsidePadding: widget.minimumOutSidePadding,
          context: context,
        );
      },
    );
  }
}

class _BallonLayoutDelegate extends SingleChildLayoutDelegate {
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double yOffset;
    double xOffset = -childSize.width / 2;
    return Offset.zero;
  }

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) {
    return false;
  }
}