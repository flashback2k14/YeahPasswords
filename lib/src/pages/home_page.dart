import 'dart:typed_data';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
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

  // StreamSubscription<NDEFMessage> _stream;

  List<ProviderItem> _items = [];

  final YeahInput providerName = YeahInput(
      labelText: "Provider name", isPassword: false, isLastInput: false);

  final YeahInput providerPassword = YeahInput(
      labelText: "Provider password", isPassword: true, isLastInput: true);

  /*
   * READ FROM NFC
   */

  void _readNfcData() {
    FlushbarHelper.createInformation(
      message: 'Start reading data...',
    ).show(context);

    setState(() {
      _items.clear();

      NfcManager.instance.startTagSession(onDiscovered: (NfcTag tag) async {
        Ndef ndef = Ndef.fromTag(tag);

        if (ndef == null) {
          const message = "Wrong NFC Tag format.";
          FlushbarHelper.createError(
            message: message,
          ).show(context);
          NfcManager.instance.stopSession(errorMessageIOS: message);
          return;
        }

        if (ndef.cachedMessage.byteLength == 0) {
          const message = 'NFC Tag is empty.';
          FlushbarHelper.createInformation(
            message: message,
          ).show(context);
          NfcManager.instance.stopSession(errorMessageIOS: message);
          return;
        }

        for (NdefRecord record in ndef.cachedMessage.records) {
          _items.add(ProviderItem.fromString(
              new String.fromCharCodes(record.payload)));
          setState(() {});
        }

        NfcManager.instance.stopSession();
      });
    });
  }

  /*
   * WRITE TO NFC
   */

  void _writeNfcData(BuildContext context) {
    FlushbarHelper.createInformation(
      message: 'Start writing data...',
    ).show(context);

    NfcManager.instance.startTagSession(onDiscovered: (NfcTag tag) async {
      FlushbarHelper.createInformation(
        message: 'NFC Tag found.',
      ).show(context);

      Ndef ndef = Ndef.fromTag(tag);
      if (ndef == null) {
        const message = "Wrong NFC Tag format.";
        FlushbarHelper.createError(
          message: message,
        ).show(context);
        NfcManager.instance.stopSession(errorMessageIOS: message);
        return;
      }

      if (!ndef.isWritable) {
        const message = "NFC Tag is not ndef writable.";
        FlushbarHelper.createError(
          message: message,
        ).show(context);
        NfcManager.instance.stopSession(errorMessageIOS: message);
        return;
      }

      try {
        List<NdefRecord> records = _items.map((providerItem) {
          return NdefRecord.createText(providerItem.toString());
        }).toList();
        NdefMessage message = NdefMessage(records);

        await ndef.write(message);

        FlushbarHelper.createSuccess(
          message: "Successfully saved the data.",
        ).show(context);
        NfcManager.instance.stopSession();
      } catch (e) {
        FlushbarHelper.createError(
          message: e.toString(),
        ).show(context);
        NfcManager.instance.stopSession(errorMessageIOS: e.toString());
      }
    });
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
              _readNfcData();
            },
            child: Icon(
              CommunityMaterialIcons.download_outline,
            ),
          )),
      Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () {
              _writeNfcData(context);
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
