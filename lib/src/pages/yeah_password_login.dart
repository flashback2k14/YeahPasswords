import 'package:flutter/material.dart';
import 'package:yeah_passwords/src/pages/yeah_password_home.dart';

class YeahPasswordLoginPage extends StatefulWidget {
  YeahPasswordLoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _YeahPasswordLoginPageState createState() => _YeahPasswordLoginPageState();
}

class _YeahPasswordLoginPageState extends State<YeahPasswordLoginPage> {
  TextEditingController userNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  void _login(BuildContext context) {
    if (userNameController.text == "lorem" &&
        passwordController.text == "ipsum") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => YeahPasswordHomePage(
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
                        OutlineButton(
                          child: new Text("Sign In"),
                          onPressed: () => _login(context),
                        ),
                      ])))),
    );
  }
}
