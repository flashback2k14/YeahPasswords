import 'package:flutter/material.dart';

class YeahPasswordHomePage extends StatefulWidget {
  YeahPasswordHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _YeahPasswordHomePageState createState() => _YeahPasswordHomePageState();
}

class _YeahPasswordHomePageState extends State<YeahPasswordHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Go back!'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
