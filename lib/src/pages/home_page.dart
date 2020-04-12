import 'package:community_material_icon/community_material_icon.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:yeah_passwords/src/models/provider-item_model.dart';
import 'package:yeah_passwords/src/pages/signin_page.dart';
import 'package:yeah_passwords/src/widgets/yeah_button.dart';
import 'package:yeah_passwords/src/widgets/yeah_fab.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;
  static final String navigationRoute = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform =
      const MethodChannel('com.yeahdev.yeah_passwords/intent');

  double _cardSize;
  List<ProviderItem> _items = [];

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
        ProviderItem item = ProviderItem.fromUint8List(
          ndef?.cachedMessage?.records?.first?.payload,
        );

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
                  'text/plain',
                  ProviderItem.createEmptyItem().toUint8List(),
                )
              ]
            : _items
                .map(
                  (providerItem) => NdefRecord.createMime(
                    'text/plain',
                    providerItem.toUint8List(),
                  ),
                )
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
   * LISTVIEW ACTIONS
   */

  void _handleProviderItemSubmitted(ProviderItem providerItem) {
    _items.add(providerItem);
    setState(() {});
  }

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
    _cardSize = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
        actions: _createToolbarActions(context),
        bottom: _createToolbarBottom(),
      ),
      body: Container(
        child: _createListview(),
      ),
      floatingActionButton: YeahFab(
        onProviderItemSubmitted: this._handleProviderItemSubmitted,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _createBottomNavBar(),
    );
  }

  /*
   * CREATE WIDGETS
   */

  List<Widget> _createToolbarActions(BuildContext context) {
    return <Widget>[
      Tooltip(
        message: 'Logout',
        child: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, SigninPage.navigationRoute);
            },
            child: const Icon(CommunityMaterialIcons.logout_variant),
          ),
        ),
      ),
    ];
  }

  PreferredSize _createToolbarBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        height: 48.0,
        alignment: Alignment.center,
        child: LinearProgressIndicator(
          value: _cardSize,
        ),
      ),
    );
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
                    const SizedBox(height: 24.0),
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
        : ListView.separated(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: ListTile(
                  leading: Tooltip(
                    message: 'Provider name',
                    child: const Icon(
                        CommunityMaterialIcons.alpha_p_circle_outline),
                  ),
                  title: Text(
                    '${_items[index].name}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(CommunityMaterialIcons.delete_outline),
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
                              child: const Text('Copy'),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: _items[index].password),
                                );
                                FlushbarHelper.createInformation(
                                  message: 'Provider password copied.',
                                ).show(context);
                              },
                            ),
                            FlatButton(
                              child: const Text('Close'),
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

  BottomAppBar _createBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Tooltip(
            message: 'Load data from NFC tag.',
            child: IconButton(
              icon: const Icon(CommunityMaterialIcons.download_outline),
              padding: const EdgeInsets.only(left: 12.0),
              onPressed: () {
                _readNfcData();
              },
            ),
          ),
          Tooltip(
            message: 'Save data to NFC tag.',
            child: IconButton(
              icon: const Icon(CommunityMaterialIcons.upload_outline),
              padding: const EdgeInsets.only(right: 12.0),
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
