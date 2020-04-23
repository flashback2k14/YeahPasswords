import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

class YeahInput extends StatefulWidget {
  YeahInput({
    Key key,
    this.labelText,
    this.isPassword,
    this.isLastInput,
  }) : super(key: key);

  final String labelText;
  final bool isPassword;
  final bool isLastInput;

  final TextEditingController controller = new TextEditingController();

  String getText() {
    return controller.text.trim();
  }

  void clear() {
    if (controller.text.isNotEmpty) {
      Future.delayed(Duration(microseconds: 500), () {
        controller.clear();
      });
    }
  }

  @override
  _YeahInputState createState() => new _YeahInputState();
}

class _YeahInputState extends State<YeahInput> {
  FocusNode _focusNode;
  bool _showPassword;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _showPassword = widget.isPassword;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _showPassword,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: widget.labelText,
          border: OutlineInputBorder(),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(_showPassword
                      ? CommunityMaterialIcons.eye_outline
                      : CommunityMaterialIcons.eye_off_outline),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                )
              : null),
      textInputAction:
          widget.isLastInput ? TextInputAction.done : TextInputAction.next,
      onSubmitted: (_) =>
          widget.isLastInput ? _focusNode.unfocus() : _focusNode.nextFocus(),
    );
  }
}
