import 'dart:math';

import 'package:example/basics_example_page.dart';
import 'package:flutter/material.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'animated_example_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OptionsPage(),
    );
  }
}

class OptionsPage extends StatelessWidget {
  const OptionsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple Tooltip"),
      ),
      body: Container(
        height: double.infinity,
        width: double.maxFinite,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("Animated example"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) =>
                        AnimatedExamplePage(title: 'Flutter Demo Home Page'),
                  ));
                },
              ),
              RaisedButton(
                child: Text("Basics"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => BasicsExamplePage(),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
