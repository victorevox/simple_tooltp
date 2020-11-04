part of tooltip;

class _Ballon extends StatefulWidget {
  final TooltipDirection tooltipDirection;
  // final Offset targetCenter;
  final double borderRadius;
  final double arrowBaseWidth;
  final double arrowTipDistance;
  final Color borderColor;
  final double borderWidth;
  // final double left;
  // final double top;
  // final double right;
  // final double bottom;
  final double arrowLength;
  final Widget content;
  final EdgeInsets ballonPadding;
  final Color backgroundColor;
  final List<BoxShadow> shadows;
  final Function onTap;
  final Function(_BallonSize) onSizeChange;

  const _Ballon({
    Key key,
    // this.left,
    // this.top,
    // this.right,
    // this.bottom,
    @required this.tooltipDirection,
    @required this.borderRadius,
    @required this.arrowBaseWidth,
    @required this.arrowTipDistance,
    @required this.borderColor,
    @required this.borderWidth,
    @required this.arrowLength,
    @required this.content,
    @required this.ballonPadding,
    @required this.backgroundColor,
    @required this.shadows,
    this.onTap,
    @required this.onSizeChange,
  }) : super(key: key);

  @override
  __BallonState createState() => __BallonState();
}

class __BallonState extends State<_Ballon> {
  _BallonSize _lastSizeNotified;

  GlobalKey _containerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      final RenderBox renderBox = _containerKey.currentContext.findRenderObject();
      final Size size = renderBox.size;
      if (renderBox == null) return null;
      final position = renderBox.localToGlobal(Offset.zero);
      // print("position : ${position.dx},${position.dy}, Size: ${renderBox.size}");

      if (_lastSizeNotified == null || _lastSizeNotified.size != size || _lastSizeNotified.globalPosition != position) {
        final ballonSize = _BallonSize(
          size: size,
          globalPosition: position,
          context: context,
        );
        widget.onSizeChange?.call(ballonSize);
        _lastSizeNotified = ballonSize;
      }
    });
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      child: Container(
        key: _containerKey,
        decoration: ShapeDecoration(
          shadows: widget.shadows,
          color: widget.backgroundColor,
          shape: _BalloonShape(
            widget.tooltipDirection,
            Offset.zero,
            widget.borderRadius,
            widget.arrowBaseWidth,
            widget.arrowTipDistance,
            widget.borderColor,
            widget.borderWidth,
            // left,
            // top,
            // right,
            // bottom,
            widget.arrowLength,
          ),
        ),
        padding: widget.ballonPadding,
        child: widget.content,
      ),
    );
  }
}

class _BalloonShape extends ShapeBorder {
  final Offset targetCenter;
  final double arrowBaseWidth;
  final double arrowTipDistance;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final TooltipDirection tooltipDirection;
  final double arrowLength;
  // final double left, top, right, bottom;

  _BalloonShape(
    this.tooltipDirection,
    this.targetCenter,
    this.borderRadius,
    this.arrowBaseWidth,
    this.arrowTipDistance,
    this.borderColor,
    this.borderWidth,
    this.arrowLength,
    // this.left,
    // this.top,
    // this.right,
    // this.bottom,
  );

  @override
  EdgeInsetsGeometry get dimensions => new EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return new Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    //
    double topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius;

    Path _getLeftTopPath(Rect rect) {
      return new Path()
        ..moveTo(rect.left, rect.bottom - bottomLeftRadius)
        ..lineTo(rect.left, rect.top + topLeftRadius)
        ..arcToPoint(Offset(rect.left + topLeftRadius, rect.top), radius: new Radius.circular(topLeftRadius))
        ..lineTo(rect.right - topRightRadius, rect.top)
        ..arcToPoint(Offset(rect.right, rect.top + topRightRadius),
            radius: new Radius.circular(topRightRadius), clockwise: true);
    }

    Path _getBottomRightPath(Rect rect) {
      return new Path()
        ..moveTo(rect.left + bottomLeftRadius, rect.bottom)
        ..lineTo(rect.right - bottomRightRadius, rect.bottom)
        ..arcToPoint(Offset(rect.right, rect.bottom - bottomRightRadius),
            radius: new Radius.circular(bottomRightRadius), clockwise: false)
        ..lineTo(rect.right, rect.top + topRightRadius)
        ..arcToPoint(Offset(rect.right - topRightRadius, rect.top),
            radius: new Radius.circular(topRightRadius), clockwise: false);
    }

    topLeftRadius = /* (left == 0 || top == 0) ? 0.0 : */ borderRadius;
    topRightRadius = /* (right == 0 || top == 0) ? 0.0 : */ borderRadius;
    bottomLeftRadius = /* (left == 0 || bottom == 0) ? 0.0 : */ borderRadius;
    bottomRightRadius = /* (right == 0 || bottom == 0) ? 0.0 : */ borderRadius;

    // final Offset targetCenter = this.targetCenter;
    Offset targetCenter = rect.center;
    if (tooltipDirection == TooltipDirection.right) {
      targetCenter = rect.centerLeft.translate(-arrowLength, 0);
    } else if (tooltipDirection == TooltipDirection.left) {
      targetCenter = rect.centerRight.translate(arrowLength, 0);
    }
    // print(targetCenter);

    switch (tooltipDirection) {
      //
      case TooltipDirection.down:
        return _getBottomRightPath(rect)
          ..lineTo(
              min(max(targetCenter.dx + arrowBaseWidth / 2, rect.left + borderRadius + arrowBaseWidth),
                  rect.right - topRightRadius),
              rect.top)
          ..lineTo(targetCenter.dx, rect.top - arrowLength) // up to arrow tip   \
          ..lineTo(
              max(min(targetCenter.dx - arrowBaseWidth / 2, rect.right - topLeftRadius - arrowBaseWidth),
                  rect.left + topLeftRadius),
              rect.top) //  down /

          ..lineTo(rect.left + topLeftRadius, rect.top)
          ..arcToPoint(Offset(rect.left, rect.top + topLeftRadius),
              radius: new Radius.circular(topLeftRadius), clockwise: false)
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),
              radius: new Radius.circular(bottomLeftRadius), clockwise: false);

      case TooltipDirection.up:
        return _getLeftTopPath(rect)
          ..lineTo(rect.right, rect.bottom - bottomRightRadius)
          ..arcToPoint(Offset(rect.right - bottomRightRadius, rect.bottom),
              radius: new Radius.circular(bottomRightRadius), clockwise: true)
          ..lineTo(
              min(max(targetCenter.dx + arrowBaseWidth / 2, rect.left + bottomLeftRadius + arrowBaseWidth),
                  rect.right - bottomRightRadius),
              rect.bottom)

          // up to arrow tip   \
          ..lineTo(targetCenter.dx, rect.bottom + arrowLength)

          //  down /
          ..lineTo(
              max(min(targetCenter.dx - arrowBaseWidth / 2, rect.right - bottomRightRadius - arrowBaseWidth),
                  rect.left + bottomLeftRadius),
              rect.bottom)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcToPoint(Offset(rect.left, rect.bottom - bottomLeftRadius),
              radius: new Radius.circular(bottomLeftRadius), clockwise: true)
          ..lineTo(rect.left, rect.top + topLeftRadius)
          ..arcToPoint(Offset(rect.left + topLeftRadius, rect.top),
              radius: new Radius.circular(topLeftRadius), clockwise: true);

      case TooltipDirection.left:
        return _getLeftTopPath(rect)
          ..lineTo(
              rect.right,
              max(min(targetCenter.dy - arrowBaseWidth / 2, rect.bottom - bottomRightRadius - arrowBaseWidth),
                  rect.top + topRightRadius))
          ..lineTo(targetCenter.dx - arrowTipDistance, targetCenter.dy) // right to arrow tip   \
          //  left /
          ..lineTo(rect.right, min(targetCenter.dy + arrowBaseWidth / 2, rect.bottom - bottomRightRadius))
          ..lineTo(rect.right, rect.bottom - borderRadius)
          ..arcToPoint(Offset(rect.right - bottomRightRadius, rect.bottom),
              radius: new Radius.circular(bottomRightRadius), clockwise: true)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcToPoint(Offset(rect.left, rect.bottom - bottomLeftRadius),
              radius: new Radius.circular(bottomLeftRadius), clockwise: true);

      case TooltipDirection.right:
        return _getBottomRightPath(rect)
          ..lineTo(rect.left + topLeftRadius, rect.top)
          ..arcToPoint(Offset(rect.left, rect.top + topLeftRadius),
              radius: new Radius.circular(topLeftRadius), clockwise: false)
          ..lineTo(
              rect.left,
              max(min(targetCenter.dy - arrowBaseWidth / 2, rect.bottom - bottomLeftRadius - arrowBaseWidth),
                  rect.top + topLeftRadius))

          //left to arrow tip   /
          ..lineTo(targetCenter.dx + arrowTipDistance, targetCenter.dy)

          //  right \
          ..lineTo(rect.left, min(targetCenter.dy + arrowBaseWidth / 2, rect.bottom - bottomLeftRadius))
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),
              radius: new Radius.circular(bottomLeftRadius), clockwise: false);

      default:
        throw AssertionError(tooltipDirection);
    }
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    Paint paint = new Paint()
      // if borderWidth is set to 0, set the color to be transparent to avoid border to be visible because strange behavior
      ..color = borderWidth == 0 ? Color(0x00000000) : borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(getOuterPath(rect), paint);
    canvas.clipPath(getOuterPath(rect));
  }

  @override
  ShapeBorder scale(double t) {
    return new _BalloonShape(
      tooltipDirection,
      targetCenter,
      borderRadius,
      arrowBaseWidth,
      arrowTipDistance,
      borderColor,
      borderWidth,
      arrowLength,
      // left,
      // top,
      // right,
      // bottom,
    );
  }
}

class _BallonSize {
  final Size size;
  final Offset globalPosition;
  final BuildContext context;
  _BallonSize({
    @required this.size,
    @required this.globalPosition,
    @required this.context,
  });
}
