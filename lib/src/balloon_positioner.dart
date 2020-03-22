part of tooltip;

class _BallonPositioner extends StatelessWidget {
  final BuildContext context;
  final TooltipDirection tooltipDirection;
  // final Offset targetCenter;
  // final double borderRadius;
  // final double arrowBaseWidth;
  final double arrowTipDistance;
  final double arrowLength;
  // final Color borderColor;
  // final double borderWidth;
  // final double left;
  // final double top;
  // final double right;
  // final double bottom;
  final Widget child;
  final double maxWidth;
  final double maxHeight;
  final double minWidth;
  final double minHeight;
  final double outsidePadding;
  final LayerLink link;

  const _BallonPositioner({
    Key key,
    @required this.tooltipDirection,
    @required this.arrowTipDistance,
    @required this.arrowLength,
    // @required this.arrowBaseWidth,
    @required this.child,
    @required this.maxWidth,
    @required this.maxHeight,
    @required this.minWidth,
    @required this.minHeight,
    @required this.outsidePadding,
    @required this.link,
    @required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext _) {
    if(context == null) {
      return Container();
    }
    RenderBox renderBox = context.findRenderObject();
    if(!renderBox.attached) {
      return Container();
    }
    final cOverlay = Overlay.of(context);
    if(!cOverlay.mounted) {
      return Container();
    }
    final RenderBox overlay = cOverlay.context.findRenderObject();

    Offset tipTarget;

    final Offset zeroOffset = Offset.zero;
    if (tooltipDirection == TooltipDirection.up) {
      tipTarget = renderBox.size.topCenter(zeroOffset);
    } else if (tooltipDirection == TooltipDirection.down) {
      tipTarget = renderBox.size.bottomCenter(zeroOffset);
    } else if (tooltipDirection == TooltipDirection.right) {
      tipTarget = renderBox.size.centerRight(zeroOffset);
    } else if (tooltipDirection == TooltipDirection.left) {
      tipTarget = renderBox.size.centerLeft(zeroOffset);
    }

    final globalTipTarget = renderBox.localToGlobal(
      tipTarget,
      ancestor: overlay,
    );

    return CompositedTransformFollower(
      link: link,
      showWhenUnlinked: false,
      offset: tipTarget, //
      child: Stack(
        children: <Widget>[
          Positioned(
            child: CustomSingleChildLayout(
              delegate: _PopupBallonLayoutDelegate(
                arrowLength: arrowLength,
                arrowTipDistance: arrowTipDistance,
                maxHeight: maxHeight,
                maxWidth: maxWidth,
                minHeight: minHeight,
                minWidth: minWidth,
                tooltipDirection: tooltipDirection,
                tipTarget: globalTipTarget,
                outsidePadding: outsidePadding,
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                  Positioned(
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopupBallonLayoutDelegate extends SingleChildLayoutDelegate {
  final double maxWidth;
  final double maxHeight;
  final double minWidth;
  final double minHeight;
  final TooltipDirection tooltipDirection;
  final double arrowTipDistance;
  final double arrowLength;
  final Offset tipTarget;
  final double outsidePadding;

  _PopupBallonLayoutDelegate({
    @required this.maxWidth,
    @required this.maxHeight,
    @required this.minWidth,
    @required this.minHeight,
    @required this.tooltipDirection,
    @required this.arrowLength,
    @required this.arrowTipDistance,
    @required this.tipTarget,
    @required this.outsidePadding,
  });

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) {
    return false;
  }

  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxWidth = this.maxWidth ?? constraints.maxWidth;
    double maxHeight = this.maxHeight ?? constraints.maxHeight;
    double minWidth = this.minWidth ?? constraints.minWidth;
    double minHeight = this.minHeight ?? constraints.minHeight;

    if (tooltipDirection == TooltipDirection.up ||
        tooltipDirection == TooltipDirection.down) {
      maxWidth = max(
        min(
          (constraints.maxWidth - tipTarget.dx).abs() * 2 - outsidePadding,
          (tipTarget.dx).abs() * 2 - outsidePadding,
        ),
        0,
      );
      maxHeight = max(
        constraints.maxHeight - outsidePadding,
        0,
      );
    } else if (tooltipDirection == TooltipDirection.right) {
      maxWidth = max(
        (constraints.maxWidth - tipTarget.dx).abs() -
            outsidePadding -
            arrowLength -
            arrowTipDistance,
        0,
      );
      maxHeight = max(
        constraints.maxHeight - outsidePadding,
        0,
      );
    } else if (tooltipDirection == TooltipDirection.left) {
      maxWidth = max(
          min(
            tipTarget.dx >= constraints.maxWidth
                ? (constraints.maxWidth - tipTarget.dx).abs() -
                    outsidePadding -
                    arrowLength -
                    arrowTipDistance
                : maxWidth,
            // (constraints.maxWidth - tipTarget.dx).abs() - outsidePadding - arrowLength - arrowTipDistance,
            tipTarget.dx - (outsidePadding * 2) - arrowTipDistance,
          ),
          0);
      maxHeight = max(
        constraints.maxHeight - outsidePadding,
        0,
      );
    }

    return BoxConstraints(
      maxHeight: this.maxHeight ?? maxHeight,
      maxWidth: this.maxWidth ?? maxWidth,
      minHeight: this.minHeight ?? minHeight,
      minWidth: this.minWidth ?? minWidth,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    Offset ballonOffset;
    final double halfH = childSize.height / 2;
    final double halfW = childSize.width / 2;
    Offset centerPosition = Offset(-halfW, -halfH);
    final xMin = outsidePadding + halfW;
    if (tooltipDirection == TooltipDirection.up) {
      final double yOffset = -halfH - arrowLength - arrowTipDistance;
      ballonOffset = centerPosition.translate(0, yOffset);
    } else if (tooltipDirection == TooltipDirection.down) {
      final double yOffset = halfH + arrowLength + arrowTipDistance;
      ballonOffset = centerPosition.translate(0, yOffset);
    } else if (tooltipDirection == TooltipDirection.right) {
      final double xOffset = halfW + arrowLength + arrowTipDistance;
      ballonOffset = centerPosition.translate(xOffset, 0);
    } else if (tooltipDirection == TooltipDirection.left) {
      final double xOffset = -halfW - arrowLength - arrowTipDistance;
      ballonOffset = centerPosition.translate(xOffset, 0);
    } else {
      ballonOffset = centerPosition;
    }
    return ballonOffset;
  }
}
