import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _textEditingController =
      new TextEditingController();
  StreamSubscription<NDEFMessage> _stream;

  List<String> items = [];

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _startScanning() {
    setState(() {
      items.clear();

      _stream = NFC
          .readNDEF(alertMessage: "Custom message")
          .listen((NDEFMessage message) {
        if (message.isEmpty) {
          _showSnackbar("read empty ndef message");
          return;
        }
        _showSnackbar("ndef message ${message.records.length} records.");

        for (NDEFRecord record in message.records) {
          items.add(record.data);
          setState(() {});
        }
      });
    });
  }

  void _stopScanning() {
    _stream?.cancel();
    setState(() {
      _stream = null;
    });
  }

  void _toggleScan() {
    if (_stream == null) {
      _showSnackbar("start...");
      _startScanning();
    } else {
      _showSnackbar("stop...");
      _stopScanning();
    }
  }

  void _write(BuildContext context) async {
    List<NDEFRecord> records = items.map((record) {
      return NDEFRecord.plain(record);
    }).toList();
    NDEFMessage message = NDEFMessage.withRecords(records);

    // Show dialog on Android (iOS has it's own one)
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Scan the tag you want to write to"),
          actions: <Widget>[
            FlatButton(
              child: const Text("Cancel"),
              onPressed: () {
                _stream?.cancel();
                return;
              },
            ),
          ],
        ),
      );
    }

    // Write to the first tag scanned
    await NFC.writeNDEF(message).first;
    _showSnackbar("successfully saved");
  }

  void _onAddItemPressed() {
    _scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
      return new Container(
        decoration: new BoxDecoration(color: Colors.blueGrey),
        child: new Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 50.0, 32.0, 32.0),
          child: new TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: 'Please enter a task',
            ),
            onSubmitted: _onSubmit,
          ),
        ),
      );
    });
  }

  _onSubmit(String s) {
    if (s.isNotEmpty) {
      items.add(s);
      _textEditingController.clear();
      setState(() {});
    }
  }

  _onDeleteItemPressed(item) {
    items.removeAt(item);
    setState(() {});
  }

  @override
  void dispose() {
    _stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () {
                  _toggleScan();
                },
                child: Icon(
                  Icons.file_download,
                  size: 26.0,
                ),
              )),
          Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () {
                  _write(context);
                },
                child: Icon(
                  Icons.file_upload,
                  size: 26.0,
                ),
              )),
          Padding(
              padding: EdgeInsets.only(right: 12.0),
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
      body: new Container(
        child: new ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                '${items[index]}',
              ),
              trailing: new IconButton(
                icon: new Icon(Icons.delete),
                onPressed: () {
                  _onDeleteItemPressed(index);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _onAddItemPressed();
        },
        tooltip: 'Add task',
        child: new Icon(Icons.add),
      ),
    );
  }
}

// https://github.com/guivazcabral/flutter_todo/blob/master/lib/main.dart
// https://github.com/semlette/nfc_in_flutter/blob/master/example/lib/write_example_screen.dart
