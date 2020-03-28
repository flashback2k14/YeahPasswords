import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/models/user_model.dart';
import 'package:yeah_passwords/src/repositories/user_repository.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class SignupPage extends StatefulWidget {
  SignupPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  YeahInput usernameInput = YeahInput(labelText: "Username", isPassword: false);
  YeahInput passwordInput = YeahInput(labelText: "Password", isPassword: true);
  YeahInput confirmPasswordInput =
      YeahInput(labelText: "Confirm Password", isPassword: true);

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

  Future _createNewUser() async {
    List<int> bytes = utf8.encode(passwordInput.getText());
    Digest passwordHash = sha256.convert(bytes);

    User newUser = User(
        name: usernameInput.getText(), passwordHash: passwordHash.toString());

    await UserRepository().insert(newUser);
  }

  void _performSignUp(BuildContext context) async {
    if (passwordInput.getText() != confirmPasswordInput.getText()) {
      _buildDialog(context, "Passwords not matching.");
      return;
    }

    User foundUser = await UserRepository().findByName(usernameInput.getText());
    if (foundUser != null) {
      _buildDialog(context, "User already registerd.");
      return;
    }

    await _createNewUser();

    Navigator.pushNamed(context, "/home");
  }

  ButtonTheme _buildSignUpButtonTheme(BuildContext context, String buttonText) {
    return ButtonTheme(
      height: 48,
      minWidth: double.infinity,
      child: RaisedButton(
        child: Text(buttonText),
        textColor: Colors.white,
        onPressed: () => _performSignUp(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
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
                        confirmPasswordInput,
                        SizedBox(height: 24.0),
                        _buildSignUpButtonTheme(context, "Sign Up"),
                      ])))),
    );
  }
}
