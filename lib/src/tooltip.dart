library tooltip;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'types.dart';

part 'balloon.dart';
part 'balloon_positioner.dart';
part 'ballon_transition.dart';

class SimpleTooltip extends StatefulWidget {
  /// The [child] which the tooltip will target to
  final Widget child;

  /// Sets the tooltip direction
  /// defaults to [TooltipDirection.up]
  final TooltipDirection tooltipDirection;

  /// Defines the content that its placed inside the tooltip ballon
  final Widget content;

  /// If true, it will display the tool , if false it will hide it
  final bool show;

  final Function onClose;

  /// Sets the content padding
  /// defautls to: `const EdgeInsets.symmetric(horizontal: 20, vertical: 16),`
  final EdgeInsets ballonPadding;

  /// sets the duration of the tooltip entrance animation
  /// defaults to [460] milliseconds
  final Duration animationDuration;

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

  ///
  /// The color of the border
  final Color backgroundColor;

  ///
  /// Set a custom list of [BoxShadow]
  /// defaults to `const BoxShadow(color: const Color(0x45222222), blurRadius: 8, spreadRadius: 2),`
  final List<BoxShadow> customShadows;

  final Function() tooltipTap;

  SimpleTooltip({
    Key key,
    this.child,
    this.tooltipDirection = TooltipDirection.up,
    this.content,
    @required this.show,
    this.onClose,
    this.ballonPadding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.maxWidth,
    this.minWidth,
    this.maxHeight,
    this.minHeight,
    this.arrowTipDistance = 6,
    this.arrowLength = 20,
    this.minimumOutSidePadding = 20.0,
    this.arrowBaseWidth = 20.0,
    this.borderRadius = 10,
    this.borderWidth = 2.0,
    this.borderColor = const Color(0xFF50FFFF),
    this.animationDuration = const Duration(milliseconds: 460),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.customShadows = const [
      const BoxShadow(
          color: const Color(0x45222222), blurRadius: 8, spreadRadius: 2),
    ],
    this.tooltipTap,
  })  : assert(show != null),
        super(key: key);

  @override
  _SimpleTooltipState createState() => _SimpleTooltipState();
}

class _SimpleTooltipState extends State<SimpleTooltip> {
  bool _displaying = false;

  final LayerLink layerLink = LayerLink();

  // To avoid rebuild state of widget for each rebuild
  GlobalKey _transitionKey = GlobalKey();

  OverlayEntry overlayEntry;

  @override 
  void dispose() {
    _hideTooltip();

    super.dispose();
  }

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
      if (oldWidget.tooltipDirection != widget.tooltipDirection) {
        _transitionKey = GlobalKey();
      }
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
          child: _BalloonTransition(
            key: _transitionKey,
            duration: widget.animationDuration,
            tooltipDirection: widget.tooltipDirection,
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
              backgroundColor: widget.backgroundColor,
              shadows: widget.customShadows,
              onTap: widget.tooltipTap,
            ),
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
