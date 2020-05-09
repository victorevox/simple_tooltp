import 'package:flutter/material.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class BasicsExamplePage extends StatefulWidget {
  const BasicsExamplePage({Key key}) : super(key: key);

  @override
  _BasicsExamplePageState createState() => _BasicsExamplePageState();
}

class _BasicsExamplePageState extends State<BasicsExamplePage> {
  bool _show = false;
  bool hideOnTap = false;
  TooltipDirection _direction = TooltipDirection.up;
  bool _changeBorder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Basics"),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text("change direction"),
                onPressed: () {
                  setState(() {
                    switch (_direction) {
                      case TooltipDirection.up:
                        _direction = TooltipDirection.right;
                        break;
                      case TooltipDirection.right:
                        _direction = TooltipDirection.down;
                        break;
                      case TooltipDirection.down:
                        _direction = TooltipDirection.left;
                        break;
                      case TooltipDirection.left:
                        _direction = TooltipDirection.up;
                        break;
                      default:
                    }
                  });
                },
              ),
              RaisedButton(
                child: Text("toogle: $_show"),
                onPressed: () {
                  setState(() {
                    _show = !_show;
                  });
                },
              ),
              RaisedButton(
                child: Text("hideOnTap: $hideOnTap"),
                onPressed: () {
                  setState(() {
                    hideOnTap = !hideOnTap;
                  });
                },
              ),
              RaisedButton(
                child: Text("change border: $hideOnTap"),
                onPressed: () {
                  setState(() {
                    _changeBorder = !_changeBorder;
                  });
                },
              ),
              Align(
                alignment: AlignmentDirectional.center,
                child: SimpleTooltip(
                  show: _show,
                  tooltipDirection: _direction,
                  hideOnTooltipTap: hideOnTap,
                  borderWidth: _changeBorder ? 0 : 3,
                  child: Container(
                    color: Colors.cyan,
                    width: 80,
                    height: 80,
                  ),
                  minWidth: 200,
                  content: Container(
                    width: 200,
                    child: Text("content!"),
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
