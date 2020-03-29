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
  YeahInput usernameInput = YeahInput(
    labelText: "Username",
    isPassword: false,
    isLastInput: false,
  );
  YeahInput passwordInput = YeahInput(
    labelText: "Password",
    isPassword: true,
    isLastInput: false,
  );
  YeahInput confirmPasswordInput = YeahInput(
    labelText: "Confirm Password",
    isPassword: true,
    isLastInput: true,
  );

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future _createNewUser() async {
    List<int> bytes = utf8.encode(passwordInput.getText());
    Digest passwordHash = sha256.convert(bytes);

    User newUser = User(
        name: usernameInput.getText(), passwordHash: passwordHash.toString());

    await UserRepository().insert(newUser);
  }

  void _performSignUp(BuildContext context) async {
    if (usernameInput.getText().isEmpty ||
        passwordInput.getText().isEmpty ||
        confirmPasswordInput.getText().isEmpty) {
      _showSnackbar(context, "Empty inputs not allowed.");
      return;
    }

    if (passwordInput.getText() != confirmPasswordInput.getText()) {
      _showSnackbar(context, "Passwords not matching.");
      return;
    }

    User foundUser = await UserRepository().findByName(usernameInput.getText());
    if (foundUser != null) {
      _showSnackbar(context, "User already registerd.");
      return;
    }

    await _createNewUser();

    usernameInput.clear();
    passwordInput.clear();
    confirmPasswordInput.clear();

    Navigator.pushNamed(context, "/home");
  }

  ButtonTheme _buildSignUpButtonTheme(BuildContext context, String buttonText) {
    return ButtonTheme(
      height: 48,
      minWidth: double.infinity,
      child: RaisedButton(
        child: Text(buttonText),
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
                            confirmPasswordInput,
                            SizedBox(height: 24.0),
                            _buildSignUpButtonTheme(context, "Sign Up"),
                          ]))));
        }));
  }
}
