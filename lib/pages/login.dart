import 'package:flutter/material.dart';
import 'package:inventaris/components/navbar.dart';
import 'package:inventaris/pages/background.dart';
import 'package:inventaris/modules/auth_model.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _loginController = LoginController();
  bool _isObscured = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

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
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
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
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                width: size.width * 0.8,
                decoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(29),
                ),
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
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                width: size.width * 0.8,
                decoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(29),
                ),
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
              Container(
                width: size.width * 0.8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(29),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 29, horizontal: 40),
                      backgroundColor: kPrimaryColor,
                    ),
                    onPressed: () async {
                      var response = await _loginController.login();

                      if (response is MyResponse<User>) {
                        if (response.token != null &&
                            response.token!.isNotEmpty) {
                          Navigator.pushReplacement(
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
                              content: Text(response.message),
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
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
