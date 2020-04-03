import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/models/user_model.dart';
import 'package:yeah_passwords/src/repositories/user_repository.dart';
import 'package:yeah_passwords/src/widgets/yeah_button.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class SigninPage extends StatefulWidget {
  SigninPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  YeahInput usernameInput = YeahInput(
    labelText: "Username",
    isPassword: false,
    isLastInput: false,
  );
  YeahInput passwordInput = YeahInput(
    labelText: "Password",
    isPassword: true,
    isLastInput: true,
  );

  void _showSnackbar(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _performLogin(BuildContext context) async {
    if (usernameInput.getText().isEmpty || passwordInput.getText().isEmpty) {
      _showSnackbar(context, "Empty inputs not allowed.");
      return;
    }

    User foundUser = await UserRepository().findByName(usernameInput.getText());
    if (foundUser == null) {
      _showSnackbar(context, "User not found.");
      return;
    }

    List<int> bytes = utf8.encode(passwordInput.getText());
    Digest enteredPasswordHash = sha256.convert(bytes);

    if (enteredPasswordHash.toString() != foundUser.passwordHash) {
      _showSnackbar(context, "Password is not matching.");
      return;
    }

    usernameInput.clear();
    passwordInput.clear();

    Navigator.pushReplacementNamed(context, "/home");
  }

  void _performNavigation(BuildContext context) {
    Navigator.pushNamed(context, "/signup");
  }

  @override
  Widget build(BuildContext context) {
    YeahButton signInButton = YeahButton(
        buttonText: "Sign In",
        isSecondary: false,
        onPressed: () => _performLogin(context));

    YeahButton signUpButton = YeahButton(
        buttonText: "Sign Up",
        isSecondary: true,
        onPressed: () => _performNavigation(context));

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          automaticallyImplyLeading: false,
        ),
        body: Builder(builder: (BuildContext context) {
          return Center(
              child: Container(
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
                            signInButton,
                            SizedBox(height: 12.0),
                            signUpButton,
                          ]))));
        }));
  }
}
