import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/models/provider-item_model.dart';
import 'package:yeah_passwords/src/widgets/yeah_button.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class YeahFab extends StatefulWidget {
  YeahFab({
    Key key,
    this.onProviderItemSubmitted,
  }) : super(key: key);

  final Function onProviderItemSubmitted;

  @override
  _YeahFabState createState() => new _YeahFabState();
}

class _YeahFabState extends State<YeahFab> {
  final YeahInput providerName = YeahInput(
    labelText: 'Provider name',
    isPassword: false,
    isLastInput: false,
  );

  final YeahInput providerPassword = YeahInput(
    labelText: 'Provider password',
    isPassword: true,
    isLastInput: true,
  );

  PersistentBottomSheetController _controller;
  bool _isBottomsheetVisible;

  void _openBottomSheet() {
    setState(() {
      _isBottomsheetVisible = true;
    });

    _controller = showBottomSheet(
      context: context,
      builder: (context) => _createBottomsheetContent(),
    );

    _controller.closed.then((value) {
      setState(() {
        _isBottomsheetVisible = false;
      });
    });
  }

  void _hideBottomSheet() {
    _controller.close();
  }

  Container _createBottomsheetContent() {
    return new Container(
      decoration: BoxDecoration(color: Color(0xFF212121)),
      height: 240,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 36.0, 12.0, 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            providerName,
            const SizedBox(height: 12.0),
            providerPassword,
            const SizedBox(height: 12.0),
            YeahButton(
              buttonText: 'Add entry',
              isSecondary: false,
              onPressed: () {
                if (providerName.getText().isNotEmpty &&
                    providerPassword.getText().isNotEmpty) {
                  widget.onProviderItemSubmitted(
                    ProviderItem(
                      name: providerName.getText(),
                      password: providerPassword.getText(),
                    ),
                  );
                  providerName.clear();
                  providerPassword.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isBottomsheetVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
      tooltip: 'Add item',
      elevation: 4.0,
      child: _isBottomsheetVisible
          ? const Icon(CommunityMaterialIcons.close)
          : const Icon(CommunityMaterialIcons.plus),
      onPressed: () {
        _isBottomsheetVisible ? _hideBottomSheet() : _openBottomSheet();
      },
    );
  }
}
