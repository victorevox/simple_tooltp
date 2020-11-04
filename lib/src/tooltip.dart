library tooltip;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

import 'types.dart';

part 'ballon_transition.dart';
part 'balloon.dart';
part 'balloon_positioner.dart';

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

  // TODO: Implement on close callback
  // final Function onClose;

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

  ///
  /// Set a handler for listening to a `tap` event on the tooltip (This is the recommended way to put your logic for dismissing the tooltip)
  final Function() tooltipTap;

  ///
  /// If you want to automatically dismiss the tooltip whenever a user taps on it, set this flag to [true]
  /// For more control on when to dismiss the tooltip please rely on the [show] property and [tooltipTap] handler
  /// defaults to [false]
  final bool hideOnTooltipTap;

  ///
  /// Pass a `RouteObserver` so that the widget will listen for route transition and will hide tooltip when
  /// the widget's route is not active
  final RouteObserver<PageRoute> routeObserver;

  SimpleTooltip({
    Key key,
    @required this.child,
    this.tooltipDirection = TooltipDirection.up,
    @required this.content,
    @required this.show,
    // this.onClose,
    this.ballonPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      const BoxShadow(color: const Color(0x45222222), blurRadius: 8, spreadRadius: 2),
    ],
    this.tooltipTap,
    this.hideOnTooltipTap = false,
    this.routeObserver,
  })  : assert(show != null),
        super(key: key);

  @override
  SimpleTooltipState createState() => SimpleTooltipState();
}

class SimpleTooltipState extends State<SimpleTooltip> with RouteAware {
  bool _displaying = false;

  final LayerLink layerLink = LayerLink();

  bool get shouldShowTooltip => widget.show && !_isBeingObfuscated && _routeIsShowing;

  // To avoid rebuild state of widget for each rebuild
  GlobalKey _transitionKey = GlobalKey();
  GlobalKey _positionerKey = GlobalKey();

  bool _routeIsShowing = true;

  bool _isBeingObfuscated = false;

  OverlayEntry _overlayEntry;

  List<ObfuscateTooltipItemState> _obfuscateItems = [];
  _BallonSize _ballonSize;

  addObfuscateItem(ObfuscateTooltipItemState item) {
    _obfuscateItems.add(item);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doCheckForObfuscation();
      doShowOrHide();
    });
  }

  removeObsfuscateItem(ObfuscateTooltipItemState item) {
    _obfuscateItems.remove(item);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doCheckForObfuscation();
      doShowOrHide();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // widget.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    _removeTooltip();
    widget.routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shouldShowTooltip) {
        _showTooltip();
      }
      widget.routeObserver?.subscribe(this, ModalRoute.of(context));
    });
  }

  @override
  void didUpdateWidget(SimpleTooltip oldWidget) {
    if (oldWidget.routeObserver != widget.routeObserver) {
      oldWidget.routeObserver?.unsubscribe(this);
      widget.routeObserver?.subscribe(this, ModalRoute.of(context));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (oldWidget.tooltipDirection != widget.tooltipDirection || (oldWidget.show != widget.show && widget.show)) {
        _transitionKey = GlobalKey();
      }
      if (!_routeIsShowing || _isBeingObfuscated) {
        return;
      }
      doShowOrHide();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: widget.child,
    );
  }

  void _showTooltip({
    bool buildHidding = false,
  }) {
    if (_displaying || !mounted) {
      return;
    }
    _overlayEntry = _buildOverlay(
      buildHidding: buildHidding,
    );
    Overlay.of(context, rootOverlay: false).insert(_overlayEntry);
    _displaying = true;
  }

  void _removeTooltip() {
    if (!_displaying) {
      return;
    }
    this._overlayEntry.remove();
    _displaying = false;
  }

  doShowOrHide() {
    final wasDisplaying = _displaying;
    _removeTooltip();
    if (shouldShowTooltip) {
      _showTooltip();
    } else if (wasDisplaying) {
      _showTooltip(buildHidding: true);
    }
  }

  doCheckForObfuscation() {
    if (_ballonSize == null) return;
    for (var obfuscateItem in _obfuscateItems) {
      final d = obfuscateItem.getPositionAndSize();
      // final obfuscateItemSize = d.size;
      // final obfuscateItemPosition = d.globalPosition;
      // final ballonSize = _ballonSize.size;
      // final balloPosition = _ballonSize.globalPosition;
      final Rect obfuscateItemRect = d.globalPosition & d.size;
      final Rect ballonRect = _ballonSize.globalPosition & _ballonSize.size;
      final bool overlaps = ballonRect.overlaps(obfuscateItemRect);
      if (overlaps) {
        _isBeingObfuscated = true;
        // no need to keep searching
        return;
      }
    }
    _isBeingObfuscated = false;
  }

  OverlayEntry _buildOverlay({
    bool buildHidding = false,
  }) {
    var direction = widget.tooltipDirection;

    if (direction == TooltipDirection.horizontal ||
        direction == TooltipDirection.vertical) {
      // compute real direction based on target position
      final targetRenderBox = context.findRenderObject() as RenderBox;
      final overlayRenderBox = Overlay.of(context, rootOverlay: false)
          .context
          .findRenderObject() as RenderBox;

      final targetGlobalCenter = targetRenderBox.localToGlobal(
          targetRenderBox.size.center(Offset.zero),
          ancestor: overlayRenderBox);

      direction = (direction == TooltipDirection.vertical)
          ? (targetGlobalCenter.dy <
                  overlayRenderBox.size.center(Offset.zero).dy
              ? TooltipDirection.down
              : TooltipDirection.up)
          : (targetGlobalCenter.dx <
                  overlayRenderBox.size.center(Offset.zero).dx
              ? TooltipDirection.right
              : TooltipDirection.left);
    }

    return OverlayEntry(
      builder: (overlayContext) {
        return _BallonPositioner(
          key: _positionerKey,
          link: layerLink,
          tooltipDirection: direction,
          maxHeight: widget.maxHeight,
          minHeight: widget.minHeight,
          maxWidth: widget.maxWidth,
          minWidth: widget.minWidth,
          child: _BalloonTransition(
            key: _transitionKey,
            duration: widget.animationDuration,
            tooltipDirection: direction,
            hide: buildHidding,
            animationEnd: (status) {
              if (status == AnimationStatus.dismissed) {
                _removeTooltip();
              }
            },
            child: _Ballon(
              content: widget.content,
              borderRadius: widget.borderRadius,
              arrowBaseWidth: widget.arrowBaseWidth,
              arrowLength: widget.arrowLength,
              arrowTipDistance: widget.arrowTipDistance,
              ballonPadding: widget.ballonPadding,
              borderColor: widget.borderColor,
              borderWidth: widget.borderWidth,
              tooltipDirection: direction,
              backgroundColor: widget.backgroundColor,
              shadows: widget.customShadows,
              onTap: () {
                if (widget.hideOnTooltipTap) {
                  _removeTooltip();
                  _showTooltip(buildHidding: true);
                }
                if (widget.tooltipTap != null) {
                  widget.tooltipTap();
                }
              },
              onSizeChange: (ballonSize) {
                if (!mounted) return;
                _ballonSize = ballonSize;
                doCheckForObfuscation();
                doShowOrHide();
              },
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

  @override
  void didPush() {
    _routeIsShowing = true;
    // Route was pushed onto navigator and is now topmost route.
    if (shouldShowTooltip) {
      _removeTooltip();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (!mounted) return;
        _showTooltip();
      });
    }
  }

  @override
  void didPushNext() {
    _routeIsShowing = false;
    _removeTooltip();
  }

  @override
  void didPopNext() async {
    _routeIsShowing = true;
    if (shouldShowTooltip) {
      // Covering route was popped off the navigator.
      _removeTooltip();
      await Future.delayed(Duration(milliseconds: 100));
      if (mounted) _showTooltip();
    }
  }
}
