import 'package:flutter/material.dart';

class YeahInput extends StatelessWidget {
  YeahInput({Key key, this.labelText, this.isPassword}) : super(key: key);

  final TextEditingController controller = new TextEditingController();
  final String labelText;
  final bool isPassword;

  String getText() {
    return controller.text.trim();
  }

  void clear() {
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: labelText,
      ),
    );
  }
}
