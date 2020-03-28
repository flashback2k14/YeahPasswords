import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/models/user_model.dart';
import 'package:yeah_passwords/src/repositories/user_repository.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class SigninPage extends StatefulWidget {
  SigninPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  YeahInput usernameInput = YeahInput(labelText: "Username", isPassword: false);
  YeahInput passwordInput = YeahInput(labelText: "Password", isPassword: true);

  void _buildDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
        );
      },
    );
  }

  void _performLogin(BuildContext context) async {
    User foundUser = await UserRepository().findByName(usernameInput.getText());
    if (foundUser == null) {
      _buildDialog(context, "User not found.");
      return;
    }

    List<int> bytes = utf8.encode(passwordInput.getText());
    Digest enteredPasswordHash = sha256.convert(bytes);

    if (enteredPasswordHash.toString() != foundUser.passwordHash) {
      _buildDialog(context, "Password is not matching.");
      return;
    }

    Navigator.pushNamed(context, "/home");
  }

  void _performNavigation(BuildContext context) {
    Navigator.pushNamed(context, "/signup");
  }

  ButtonTheme _buildSignInButtonTheme(BuildContext context, String buttonText) {
    return ButtonTheme(
      height: 48,
      minWidth: double.infinity,
      child: RaisedButton(
        child: Text(buttonText),
        textColor: Colors.white,
        onPressed: () => _performLogin(context),
      ),
    );
  }

  ButtonTheme _buildSignUpButtonTheme(BuildContext context, String buttonText) {
    return ButtonTheme(
      height: 48,
      minWidth: double.infinity,
      child: FlatButton(
        child: Text(buttonText),
        textColor: Colors.green,
        onPressed: () => _performNavigation(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Container(
              color: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        usernameInput,
                        SizedBox(height: 24.0),
                        passwordInput,
                        SizedBox(height: 24.0),
                        _buildSignInButtonTheme(context, "Sign In"),
                        SizedBox(height: 12.0),
                        _buildSignUpButtonTheme(context, "Sign Up"),
                      ])))),
    );
  }
}
