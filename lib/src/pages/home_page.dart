import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.popAndPushNamed(context, "/signin");
                },
                child: Icon(
                  Icons.eject,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: Center(
        child: Text('TODO: add list and inputs'),
      ),
    );
  }
}
