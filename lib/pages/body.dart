import 'package:flutter/material.dart';
import 'package:inventaris/components/navbar.dart';
import 'package:inventaris/components/rounded_button.dart';
import 'package:inventaris/components/rounded_input_field.dart';
import 'package:inventaris/components/rounded_password_field.dart';
import 'package:inventaris/components/text_field_container.dart';
import 'package:inventaris/pages/background.dart';
import 'package:inventaris/modules/login_model.dart';
import '../constants.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final LoginController _loginController = LoginController();
  bool _isObscured = true;
  final FocusNode _focusNode = FocusNode();

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });

    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Hello!",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 36),
          ),
          SizedBox(height: size.height * 0.03),
          Image.asset(
            "assets/Images/login.png",
            height: size.height * 0.35,
          ),
          SizedBox(height: size.height * 0.03),
          TextFieldContainer(
            child: TextField(
              onChanged: (value) {
                _loginController.usernameController.text = value;
              },
              decoration: InputDecoration(
                icon: Icon(
                  Icons.person,
                  color: kPrimaryColor,
                ),
                hintText: "Username",
                border: InputBorder.none,
              ),
            ),
          ),
          TextFieldContainer(
            child: TextField(
              focusNode: _focusNode,
              obscureText: _isObscured,
              onChanged: (value) {
                _loginController.passwordController.text = value;
              },
              decoration: InputDecoration(
                hintText: "Password",
                icon: Icon(
                  Icons.lock,
                  color: kPrimaryColor,
                ),
                suffixIcon: GestureDetector(
                  onTap: _toggleVisibility,
                  child: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                    color: kPrimaryColor,
                  ),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          RoundedButton(
            text: "Log In",
            press: () async {
              var response = await _loginController.login();
              if (response is MyResponse<User>) {
                if (response.token != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NavBar(),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Login Failed"),
                      content: Text(response.message ?? "Unknown error"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
          SizedBox(height: size.height * 0.03),
        ],
      ),
    );
  }
}
