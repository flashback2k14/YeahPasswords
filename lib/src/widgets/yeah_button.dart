import 'package:flutter/material.dart';

class YeahButton extends StatelessWidget {
  const YeahButton({this.buttonText, this.isSecondary, this.onPressed});

  final String buttonText;
  final bool isSecondary;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 48,
      minWidth: double.infinity,
      child: isSecondary
          ? FlatButton(child: Text(this.buttonText), onPressed: this.onPressed)
          : RaisedButton(
              child: Text(this.buttonText), onPressed: this.onPressed),
    );
  }
}
