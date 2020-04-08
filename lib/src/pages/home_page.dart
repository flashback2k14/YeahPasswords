import 'dart:async';
import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:yeah_passwords/src/models/provider-item_model.dart';
import 'package:yeah_passwords/src/pages/signin_page.dart';
import 'package:yeah_passwords/src/widgets/yeah_button.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;
  static final String navigationRoute = "/home";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform =
      const MethodChannel('com.yeahdev.yeah_passwords/intent');

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController _controller;
  bool _isBottomsheetVisible;

  StreamSubscription<NDEFMessage> _stream;

  List<ProviderItem> _items = [];

  final YeahInput providerName = YeahInput(
      labelText: "Provider name", isPassword: false, isLastInput: false);

  final YeahInput providerPassword = YeahInput(
      labelText: "Provider password", isPassword: true, isLastInput: true);

  /*
   * READ FROM NFC
   */

  void _startScanning() {
    setState(() {
      _items.clear();

      _stream = NFC
          .readNDEF(alertMessage: "Custom message")
          .listen((NDEFMessage message) {
        if (message.isEmpty) {
          FlushbarHelper.createInformation(
            message: 'The card is empty.',
          ).show(context);
          _stopScanning();
          return;
        }

        for (NDEFRecord record in message.records) {
          _items.add(ProviderItem.fromString(record.data));
          setState(() {});
        }

        _stopScanning();

        FlushbarHelper.createSuccess(
                message: "${message.records.length} records read.")
            .show(context);
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
      FlushbarHelper.createInformation(
        message: 'Start reading data...',
      ).show(context);
      _startScanning();
    } else {
      FlushbarHelper.createInformation(
        message: 'Stop reading data...',
      ).show(context);
      _stopScanning();
    }
  }

  /*
   * WRITE TO NFC
   */

  void _write(BuildContext context) async {
    _stopScanning();

    List<NDEFRecord> records = _items.map((providerItem) {
      return NDEFRecord.plain(providerItem.toString());
    }).toList();

    NDEFMessage message = NDEFMessage.withRecords(records);

    if (Platform.isAndroid) {
      FlushbarHelper.createInformation(
              message: 'Scan the tag you want to write to.')
          .show(context);
    }

    await NFC.writeNDEF(message).first;

    FlushbarHelper.createSuccess(message: 'Successfully saved the data.')
        .show(context);
  }

  /*
   * BOTTOMSHEET ACTIONS 
   */

  void _onAddItemPressed() {
    setState(() {
      _isBottomsheetVisible = true;
    });

    _controller =
        _scaffoldKey.currentState.showBottomSheet((BuildContext context) {
      return _createBottomsheetContent();
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
      _items.add(ProviderItem(
          name: providerName.getText(), password: providerPassword.getText()));
      providerName.clear();
      providerPassword.clear();
      setState(() {});
    }
  }

  /*
   * LISTVIEW ACTIONS
   */

  void _onDeleteItemPressed(item) {
    _items.removeAt(item);
    setState(() {});
  }

  /*
   * STATE ACTIONS
   */

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
        actions: _createToolbarActions(context),
      ),
      body: new Container(
        child: _createListview(),
      ),
      floatingActionButton: _createFab(),
    );
  }

  /*
   * CREATE WIDGETS
   */

  Container _createBottomsheetContent() {
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
  }

  List<Widget> _createToolbarActions(BuildContext context) {
    return <Widget>[
      Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () {
              _toggleScan();
            },
            child: Icon(
              CommunityMaterialIcons.download_outline,
            ),
          )),
      Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () {
              _write(context);
            },
            child: Icon(
              CommunityMaterialIcons.upload_outline,
            ),
          )),
      Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.popAndPushNamed(context, SigninPage.navigationRoute);
            },
            child: Icon(CommunityMaterialIcons.logout_variant),
          )),
    ];
  }

  Widget _createListview() {
    return _items.length == 0
        ? Center(
            child: Container(
                child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Please scan your Card.",
                            style: Theme.of(context).textTheme.display1,
                          ),
                          SizedBox(height: 24.0),
                          YeahButton(
                              buttonText: "Open NFC Settings",
                              isSecondary: true,
                              onPressed: () async {
                                await platform.invokeMethod("toggle_nfc_state");
                              })
                        ]))),
          )
        : new ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  '${_items[index].name}',
                ),
                subtitle: Text(
                  '${_items[index].password}',
                ),
                trailing: new IconButton(
                  icon: new Icon(CommunityMaterialIcons.delete_outline),
                  onPressed: () {
                    _onDeleteItemPressed(index);
                  },
                ),
              );
            },
          );
  }

  FloatingActionButton _createFab() {
    return new FloatingActionButton(
      child: _isBottomsheetVisible
          ? new Icon(CommunityMaterialIcons.close)
          : new Icon(CommunityMaterialIcons.plus),
      tooltip: 'Add item',
      onPressed: () {
        _isBottomsheetVisible ? _hideBottomSheet() : _onAddItemPressed();
      },
    );
  }
}

// https://pub.dev/packages/nfc_manager
// https://medium.com/flutter-community/flutter-beginners-guide-to-using-the-bottom-sheet-b8025573c433
