import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<NDEFMessage> _stream;

  void _startScanning() {
    setState(() {
      _stream = NFC
          .readNDEF(alertMessage: "Custom message")
          .listen((NDEFMessage message) {
        if (message.isEmpty) {
          print("read empty ndef message");
          return;
        }
        print("ndef message ${message.records.length} records.");

        for (NDEFRecord record in message.records) {
          print(
              "Record '${record.id ?? "[NO ID]"}' with TNF '${record.tnf}', type '${record.type}', payload '${record.payload}' and data '${record.data}' and language code '${record.languageCode}'");
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
      print("start...");
      _startScanning();
    } else {
      print("stop...");
      _stopScanning();
    }
  }

  @override
  void dispose() {
    _stopScanning();
    super.dispose();
  }

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
                    _readNfc(context);
                  },
                  child: Icon(
                    Icons.sync,
                    size: 26.0,
                  ),
                )),
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
        body: Builder(builder: (BuildContext context) {
          return Center(
              child: Container(
                  child: Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('TODO: add list and inputs'),
                            SizedBox(height: 24.0),
                            ButtonTheme(
                              height: 48,
                              minWidth: double.infinity,
                              child: FlatButton(
                                  child: Text("Read NFC"),
                                  onPressed: _toggleScan),
                            ),
                            SizedBox(height: 24.0),
                            ButtonTheme(
                              height: 48,
                              minWidth: double.infinity,
                              child: FlatButton(
                                child: Text("Write NFC"),
                                onPressed: () => _writeNfc(context),
                              ),
                            )
                          ]))));
        }));
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _readNfc(BuildContext context) async {
    NDEFMessage message = await NFC.readNDEF(once: true).first;
    _showSnackbar(context, message.payload);
    // print("payload: " + message.payload);
  }

  void _writeNfc(BuildContext context) {
    NDEFMessage newMessage =
        NDEFMessage.withRecords([NDEFRecord.plain("hello world")]);
    Stream<NDEFTag> stream = NFC.writeNDEF(newMessage, once: true);

    stream.listen((NDEFTag tag) {
      print("only wrote to one tag!");
    });
  }
}
