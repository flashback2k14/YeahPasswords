import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

class YeahInput extends StatefulWidget {
  YeahInput({this.key, this.labelText, this.isPassword, this.isLastInput});

  final Key key;
  final String labelText;
  final bool isPassword;
  final bool isLastInput;

  final TextEditingController controller = new TextEditingController();

  String getText() {
    return controller.text.trim();
  }

  void clear() {
    controller.clear();
  }

  @override
  _YeahInputState createState() => new _YeahInputState();
}

class _YeahInputState extends State<YeahInput> {
  bool _showPassword;

  @override
  void initState() {
    super.initState();
    _showPassword = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.controller,
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
        onSubmitted: (_) => widget.isLastInput
            ? FocusScope.of(context).unfocus()
            : FocusScope.of(context).nextFocus());
  }
}
