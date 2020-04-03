import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/pages/signin_page.dart';
import 'package:yeah_passwords/src/pages/signup_page.dart';
import 'package:yeah_passwords/src/pages/home_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yeah! Passwords',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.lightGreen,
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark, primarySwatch: Colors.lightGreen),
      initialRoute: "/signin",
      routes: <String, WidgetBuilder>{
        "/signin": (context) => SigninPage(
              title: 'Yeah! Password - Sign In',
            ),
        "/signup": (context) => SignupPage(
              title: 'Yeah! Password - Sign Up',
            ),
        "/home": (context) => HomePage(
              title: 'Yeah! Passwords - Home',
            )
      },
    );
  }
}
