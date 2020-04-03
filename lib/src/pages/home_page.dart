import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:yeah_passwords/src/widgets/yeah_button.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController _controller;
  bool _isBottomsheetVisible;

  StreamSubscription<NDEFMessage> _stream;

  List<String> _items = [];

  final YeahInput providerName = YeahInput(
      labelText: "Provider name", isPassword: false, isLastInput: false);
  final YeahInput providerPassword = YeahInput(
      labelText: "Provider password", isPassword: true, isLastInput: true);

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _startScanning() {
    setState(() {
      _items.clear();

      _stream = NFC
          .readNDEF(alertMessage: "Custom message")
          .listen((NDEFMessage message) {
        if (message.isEmpty) {
          _showSnackbar("The card is empty.");
          return;
        }
        _showSnackbar("${message.records.length} records read.");

        for (NDEFRecord record in message.records) {
          _items.add(record.data);
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
      _showSnackbar("start reading...");
      _startScanning();
    } else {
      _showSnackbar("stop reading...");
      _stopScanning();
    }
  }

  void _write(BuildContext context) async {
    _stopScanning();

    List<NDEFRecord> records = _items.map((record) {
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
    setState(() {
      _isBottomsheetVisible = true;
    });

    _controller =
        _scaffoldKey.currentState.showBottomSheet((BuildContext context) {
      final YeahButton submitButton = YeahButton(
          buttonText: "Add Item", isSecondary: false, onPressed: _onSubmit);

      return new Container(
        decoration: new BoxDecoration(color: Colors.black12),
        height: 260,
        child: new Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  providerName,
                  SizedBox(height: 12.0),
                  providerPassword,
                  SizedBox(height: 12.0),
                  submitButton
                ])),
      );
    });

    _controller.closed.then((value) {
      setState(() {
        _isBottomsheetVisible = false;
      });
    });
  }

  void _hideBottomSheet() {
    _controller.close();
    setState(() {
      _isBottomsheetVisible = false;
    });
  }

  void _onSubmit() {
    if (providerName.getText().isNotEmpty &&
        providerPassword.getText().isNotEmpty) {
      _items.add(providerName.getText() + " - " + providerPassword.getText());
      providerName.clear();
      providerPassword.clear();
      setState(() {});
    }
  }

  void _onDeleteItemPressed(item) {
    _items.removeAt(item);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _isBottomsheetVisible = false;
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
        child: _items.length == 0
            ? Center(child: Text("Please scan your Cards."))
            : new ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${_items[index]}',
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
        child:
            _isBottomsheetVisible ? new Icon(Icons.clear) : new Icon(Icons.add),
        tooltip: 'Add task',
        onPressed: () {
          _isBottomsheetVisible ? _hideBottomSheet() : _onAddItemPressed();
        },
      ),
    );
  }
}

// https://medium.com/flutter-community/flutter-beginners-guide-to-using-the-bottom-sheet-b8025573c433
