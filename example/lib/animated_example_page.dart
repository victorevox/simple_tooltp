import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class AnimatedExamplePage extends StatefulWidget {
  AnimatedExamplePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AnimatedExamplePageState createState() => _AnimatedExamplePageState();
}

class _AnimatedExamplePageState extends State<AnimatedExamplePage> {
  AnimationStatus _marginAnimationStatus;

  int _restartCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MarginTransition(
              animationStatusChange: (status) {
                setState(() {
                  _marginAnimationStatus = status;
                  if (status == AnimationStatus.forward) {
                    _restartCount++;
                  }
                  if (_restartCount > 4) {
                    _restartCount = 0;
                  }
                });
              },
              child: Container(
                width: 280,
                height: 120,
                child: Placeholder(),
              ),
              builder: (context, margin, child) {
                // print(_marginAnimationStatus);
                return Container(
                  margin: _marginAnimationStatus == AnimationStatus.forward
                      ? EdgeInsets.only(left: margin)
                      : EdgeInsets.only(right: margin),
                  child: SimpleTooltip(
                    tooltipTap: () {
                      print("tooltip tap ${Random().nextDouble()}");
                    },
                    backgroundColor:
                        _marginAnimationStatus == AnimationStatus.forward
                            ? Colors.white
                            : Colors.blue[300],
                    borderColor:
                        _marginAnimationStatus == AnimationStatus.forward
                            ? Colors.purple
                            : Colors.orange,
                    show: true,
                    arrowTipDistance: 10,
                    tooltipDirection: _restartCount > 2
                        ? _marginAnimationStatus == AnimationStatus.reverse
                            ? TooltipDirection.up
                            : TooltipDirection.down
                        : _marginAnimationStatus == AnimationStatus.reverse
                            ? TooltipDirection.right
                            : TooltipDirection.left,
                    child: child,
                    content: Text(
                      "Some text example!!!!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MarginTransition extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext, double margin, Widget child) builder;
  final ValueChanged<AnimationStatus> animationStatusChange;

  MarginTransition({
    Key key,
    @required this.child,
    @required this.builder,
    this.animationStatusChange,
  })  : assert(builder != null),
        super(key: key);

  @override
  _MarginTransitionState createState() => _MarginTransitionState();
}

class _MarginTransitionState extends State<MarginTransition>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    _animationController.forward();
    _animation =
        Tween<double>(begin: 10, end: 300).animate(_animationController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _animationController.forward();
            }

            if (widget.animationStatusChange != null) {
              widget.animationStatusChange(_animationController.status);
            }
          });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return widget.builder(context, _animation.value, child);
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
