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
  static final String navigationRoute = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform =
      const MethodChannel('com.yeahdev.yeah_passwords/intent');

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController _controller;
  bool _isBottomsheetVisible;

  List<ProviderItem> _items = [];
  double _cardSize;

  final YeahInput providerName = YeahInput(
      labelText: 'Provider name', isPassword: false, isLastInput: false);

  final YeahInput providerPassword = YeahInput(
      labelText: 'Provider password', isPassword: true, isLastInput: true);

  /*
   * NFC ACTIONS
   */

  void _readNfcData() {
    FlushbarHelper.createInformation(
      message: 'Start reading data...',
    ).show(context);

    setState(() {
      _items.clear();
    });

    NfcManager.instance.startTagSession(onDiscovered: (NfcTag tag) async {
      Ndef ndef = Ndef.fromTag(tag);

      if (ndef == null) {
        const message = 'Wrong NFC tag format.';
        FlushbarHelper.createError(
          message: message,
        ).show(context);
        NfcManager.instance.stopSession(errorMessageIOS: message);
        return;
      }

      if (ndef?.cachedMessage?.records?.isEmpty ?? true) {
        const message = 'NFC tag is empty.';
        FlushbarHelper.createInformation(
          message: message,
        ).show(context);
        NfcManager.instance.stopSession(errorMessageIOS: message);
        return;
      }

      if (ndef?.cachedMessage?.records?.length == 1) {
        ProviderItem item =
            ProviderItem.fromUint8List(ndef?.cachedMessage?.records[0].payload);
        if (item.isEmptyItem()) {
          const message = 'NFC tag is empty.';
          FlushbarHelper.createInformation(
            message: message,
          ).show(context);
          NfcManager.instance.stopSession(errorMessageIOS: message);
          return;
        }
      }

      for (NdefRecord record in ndef.cachedMessage.records) {
        ProviderItem item = ProviderItem.fromUint8List(record.payload);
        if (item.isEmptyItem()) {
          continue;
        }
        _items.add(item);
        setState(() {});
      }

      setState(() {
        _cardSize = ndef.cachedMessage.byteLength * 1.0 / ndef.maxSize;
      });

      NfcManager.instance.stopSession();
    });
  }

  void _writeNfcData(BuildContext context) {
    FlushbarHelper.createInformation(
      message: 'Start writing data...',
    ).show(context);

    NfcManager.instance.startTagSession(onDiscovered: (NfcTag tag) async {
      FlushbarHelper.createInformation(
        message: 'NFC tag found.',
      ).show(context);

      Ndef ndef = Ndef.fromTag(tag);
      if (ndef == null) {
        const message = 'Wrong NFC tag format.';
        FlushbarHelper.createError(
          message: message,
        ).show(context);
        NfcManager.instance.stopSession(errorMessageIOS: message);
        return;
      }

      if (!ndef.isWritable) {
        const message = 'NFC tag is not writable.';
        FlushbarHelper.createError(
          message: message,
        ).show(context);
        NfcManager.instance.stopSession(errorMessageIOS: message);
        return;
      }

      try {
        List<NdefRecord> records = _items.isEmpty
            ? [
                NdefRecord.createMime(
                    'text/plain', ProviderItem.createEmptyItem().toUint8List())
              ]
            : _items
                .map((providerItem) => NdefRecord.createMime(
                    'text/plain', providerItem.toUint8List()))
                .toList();
        NdefMessage message = NdefMessage(records);

        await ndef.write(message);

        FlushbarHelper.createSuccess(
          message: 'Successfully saved the data.',
        ).show(context);
        NfcManager.instance.stopSession();

        setState(() {
          _cardSize = message.byteLength * 1.0 / ndef.maxSize;
        });
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
    _cardSize = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: _createToolbarActions(context),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            height: 48.0,
            alignment: Alignment.center,
            child: LinearProgressIndicator(
              value: _cardSize,
            ),
          ),
        ),
      ),
      body: new Container(
        child: _createListview(),
      ),
      floatingActionButton: _createFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _createBottomNavBar(),
    );
  }

  /*
   * CREATE WIDGETS
   */

  Container _createBottomsheetContent() {
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
            YeahButton(
              buttonText: 'Add entry',
              isSecondary: false,
              onPressed: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _createToolbarActions(BuildContext context) {
    return <Widget>[
      Tooltip(
        message: 'Logout',
        child: Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, SigninPage.navigationRoute);
            },
            child: Icon(CommunityMaterialIcons.logout_variant),
          ),
        ),
      ),
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
                      'Please scan your NFC tag.',
                      style: Theme.of(context).textTheme.title,
                    ),
                    SizedBox(height: 24.0),
                    YeahButton(
                      buttonText: 'Open NFC Settings',
                      isSecondary: true,
                      onPressed: () async {
                        await platform.invokeMethod('toggle_nfc_state');
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        : new ListView.separated(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: ListTile(
                  leading: new IconButton(
                    tooltip: 'Provider name',
                    icon:
                        new Icon(CommunityMaterialIcons.alpha_p_circle_outline),
                    onPressed: () {},
                  ),
                  title: Text(
                    '${_items[index].name}',
                  ),
                  trailing: new IconButton(
                    icon: new Icon(CommunityMaterialIcons.delete_outline),
                    onPressed: () {
                      _onDeleteItemPressed(index);
                    },
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Provider password'),
                          content: Text(_items[index].password),
                          actions: [
                            FlatButton(
                              child: Text('Copy'),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: _items[index].password));
                                FlushbarHelper.createInformation(
                                  message: 'Provider password copied.',
                                ).show(context);
                              },
                            ),
                            FlatButton(
                              child: Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          );
  }

  FloatingActionButton _createFab() {
    return new FloatingActionButton(
      tooltip: 'Add item',
      elevation: 4.0,
      child: _isBottomsheetVisible
          ? new Icon(CommunityMaterialIcons.close)
          : new Icon(CommunityMaterialIcons.plus),
      onPressed: () {
        _isBottomsheetVisible ? _hideBottomSheet() : _onAddItemPressed();
      },
    );
  }

  BottomAppBar _createBottomNavBar() {
    return new BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Tooltip(
            message: 'Load data from NFC tag.',
            child: IconButton(
              icon: Icon(CommunityMaterialIcons.download_outline),
              padding: EdgeInsets.only(left: 12.0),
              onPressed: () {
                _readNfcData();
              },
            ),
          ),
          Tooltip(
            message: 'Save data to NFC tag.',
            child: IconButton(
              icon: Icon(CommunityMaterialIcons.upload_outline),
              padding: EdgeInsets.only(right: 12.0),
              onPressed: () {
                _writeNfcData(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
