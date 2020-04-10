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
        brightness: Brightness.dark,
        accentColor: Colors.cyan,
        accentTextTheme: Typography(platform: TargetPlatform.android).white,
      ),
      initialRoute: SigninPage.navigationRoute,
      routes: <String, WidgetBuilder>{
        SigninPage.navigationRoute: (context) => SigninPage(
              title: 'Yeah! Password - Sign In',
            ),
        SignupPage.navigationRoute: (context) => SignupPage(
              title: 'Yeah! Password - Sign Up',
            ),
        HomePage.navigationRoute: (context) => HomePage(
              title: 'Yeah! Passwords - Home',
            )
      },
    );
  }
}
