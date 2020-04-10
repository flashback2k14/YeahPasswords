import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/models/user_model.dart';
import 'package:yeah_passwords/src/pages/home_page.dart';
import 'package:yeah_passwords/src/repositories/user_repository.dart';
import 'package:yeah_passwords/src/widgets/yeah_button.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class SignupPage extends StatefulWidget {
  SignupPage({Key key, this.title}) : super(key: key);

  final String title;
  static final String navigationRoute = "/signup";

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final YeahInput usernameInput = YeahInput(
    labelText: "Username",
    isPassword: false,
    isLastInput: false,
  );

  final YeahInput passwordInput = YeahInput(
    labelText: "Password",
    isPassword: true,
    isLastInput: false,
  );

  final YeahInput confirmPasswordInput = YeahInput(
    labelText: "Confirm Password",
    isPassword: true,
    isLastInput: true,
  );

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
      FlushbarHelper.createError(
        title: 'Sign up error.',
        message: 'Empty inputs not allowed.',
      ).show(context);
      return;
    }

    if (passwordInput.getText() != confirmPasswordInput.getText()) {
      FlushbarHelper.createError(
        title: 'Sign up error.',
        message: 'Passwords not matching.',
      ).show(context);
      return;
    }

    User foundUser = await UserRepository().findByName(usernameInput.getText());
    if (foundUser != null) {
      FlushbarHelper.createError(
        title: 'Sign up error.',
        message: 'User already registerd.',
      ).show(context);
      return;
    }

    await _createNewUser();

    usernameInput.clear();
    passwordInput.clear();
    confirmPasswordInput.clear();

    Navigator.pushNamed(context, HomePage.navigationRoute);
  }

  @override
  Widget build(BuildContext context) {
    final YeahButton signUpButton = YeahButton(
        buttonText: "Sign up",
        isSecondary: false,
        onPressed: () => _performSignUp(context));

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
                            confirmPasswordInput,
                            SizedBox(height: 24.0),
                            signUpButton
                          ]))));
        }));
  }
}
