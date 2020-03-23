import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/pages/yeah_password_login.dart';

class YeahPasswordApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yeah! Passwords',
      theme: ThemeData(primarySwatch: Colors.green),
      home: YeahPasswordLoginPage(
        title: 'Yeah! Password - Login',
      ),
    );
  }
}
