import 'package:flutter/material.dart';
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

  void _performSignUp(BuildContext context) async {
    // var user = User(name: 'test', passwordHash: 'sldjfdhfhudf');
    // await UserRepository().insert(user);
    // List<User> users = await UserRepository().findAll();
    // print(users);

    if (passwordInput.getText() == confirmPasswordInput.getText()) {
      Navigator.pushNamed(context, "/home");
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Passwords not matching."),
          );
        },
      );
    }
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
                        SizedBox(height: 6.0),
                        _buildSignUpButtonTheme(context, "Sign Up"),
                      ])))),
    );
  }
}
