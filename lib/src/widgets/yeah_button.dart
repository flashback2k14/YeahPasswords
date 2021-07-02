import 'package:flutter/material.dart';

class YeahButton extends StatelessWidget {
  const YeahButton({
    Key key,
    this.buttonText,
    this.isSecondary,
    this.onPressed,
  }) : super(key: key);

  final String buttonText;
  final bool isSecondary;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 48,
      minWidth: double.infinity,
      child: isSecondary
          ? TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: Text(this.buttonText),
              onPressed: this.onPressed,
            )
          : ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.tealAccent),
              ),
              child: Text(this.buttonText),
              onPressed: this.onPressed,
            ),
    );
  }
}
