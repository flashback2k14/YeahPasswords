import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/pages/login_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yeah! Passwords',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginPage(
        title: 'Yeah! Password - Login',
      ),
    );
  }
}
