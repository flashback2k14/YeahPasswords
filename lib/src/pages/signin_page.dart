import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/models/user_model.dart';
import 'package:yeah_passwords/src/pages/home_page.dart';
import 'package:yeah_passwords/src/pages/signup_page.dart';
import 'package:yeah_passwords/src/repositories/user_repository.dart';
import 'package:yeah_passwords/src/widgets/yeah_button.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class SigninPage extends StatefulWidget {
  SigninPage({Key key, this.title}) : super(key: key);

  final String title;
  static final String navigationRoute = "/signin";

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final YeahInput usernameInput = YeahInput(
    labelText: "Username",
    isPassword: false,
    isLastInput: false,
  );

  final YeahInput passwordInput = YeahInput(
    labelText: "Password",
    isPassword: true,
    isLastInput: true,
  );

  void _performLogin(BuildContext context) async {
    if (usernameInput.getText().isEmpty || passwordInput.getText().isEmpty) {
      FlushbarHelper.createError(
        title: 'Sign in error.',
        message: 'Empty inputs not allowed.',
      ).show(context);
      return;
    }

    User foundUser = await UserRepository().findByName(usernameInput.getText());
    if (foundUser == null) {
      FlushbarHelper.createError(
        title: 'Sign in error.',
        message: 'User not found.',
      ).show(context);
      return;
    }

    List<int> bytes = utf8.encode(passwordInput.getText());
    Digest enteredPasswordHash = sha256.convert(bytes);

    if (enteredPasswordHash.toString() != foundUser.passwordHash) {
      FlushbarHelper.createError(
        title: 'Sign in error.',
        message: 'Password is not matching.',
      ).show(context);
      return;
    }

    usernameInput.clear();
    passwordInput.clear();

    Navigator.pushReplacementNamed(context, HomePage.navigationRoute);
  }

  void _performNavigation(BuildContext context) {
    Navigator.pushNamed(context, SignupPage.navigationRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(widget.title),
          automaticallyImplyLeading: false,
        ),
        body: Builder(builder: (BuildContext context) {
          return Center(
              child: SingleChildScrollView(
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
                            YeahButton(
                                buttonText: "Sign In",
                                isSecondary: false,
                                onPressed: () => _performLogin(context)),
                            SizedBox(height: 12.0),
                            YeahButton(
                                buttonText: "Sign Up",
                                isSecondary: true,
                                onPressed: () => _performNavigation(context)),
                          ]))));
        }));
  }
}
