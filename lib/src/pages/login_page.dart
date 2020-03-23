import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/models/user_model.dart';
import 'package:yeah_passwords/src/pages/home_page.dart';
import 'package:yeah_passwords/src/repositories/user_repository.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  void _login(BuildContext context) async {
    // var user = User(name: 'test', passwordHash: 'sldjfdhfhudf');
    // await UserRepository().insert(user);
    // List<User> users = await UserRepository().findAll();
    // print(users);

    if (userNameController.text == "lorem" &&
        passwordController.text == "ipsum") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  title: 'Yeah! Passwords - Home',
                )),
      );
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
                        TextField(
                          controller: userNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                          ),
                        ),
                        SizedBox(height: 25.0),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                        ),
                        SizedBox(height: 25.0),
                        ButtonTheme(
                          height: 48,
                          minWidth: double.infinity,
                          child: RaisedButton(
                            child: Text('Sign In'),
                            textColor: Colors.white,
                            onPressed: () => _login(context),
                          ),
                        ),
                      ])))),
    );
  }
}
