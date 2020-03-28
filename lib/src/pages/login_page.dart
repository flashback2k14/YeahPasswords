import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/widgets/yeah_input.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  YeahInput usernameInput = YeahInput(labelText: "Username", isPassword: false);
  YeahInput passwordInput = YeahInput(labelText: "Password", isPassword: true);

  void _performLogin(BuildContext context) async {
    // var user = User(name: 'test', passwordHash: 'sldjfdhfhudf');
    // await UserRepository().insert(user);
    // List<User> users = await UserRepository().findAll();
    // print(users);

    if (usernameInput.getText() == "lorem" &&
        passwordInput.getText() == "ipsum") {
      Navigator.pushNamed(context, "/home");
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Wrong credentials."),
          );
        },
      );
    }
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
                        SizedBox(height: 25.0),
                        passwordInput,
                        SizedBox(height: 25.0),
                        _buildSignInButtonTheme(context, "Sign In"),
                        SizedBox(height: 25.0),
                        _buildSignUpButtonTheme(context, "Sign Up"),
                      ])))),
    );
  }
}
