import 'package:flutter/material.dart';
import 'package:inventaris/components/already_have_an_account_acheck.dart';
import 'package:inventaris/components/rounded_button.dart';
import 'package:inventaris/components/rounded_input_field.dart';
import 'package:inventaris/components/rounded_password_field.dart';
import 'package:inventaris/constants.dart';
import 'package:inventaris/pages/background.dart';
import 'package:inventaris/pages/login.dart';
import 'package:inventaris/pages/register/or_divider.dart';
import 'package:inventaris/pages/register/social_icon.dart';

class Body extends StatelessWidget {
  final Widget child;

  const Body({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "SIGNUP",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: size.height * 0.03),
          Image.asset(
            "assets/Images/signup.png",
            height: size.height * 0.35,
          ),
          RoudedInputField(
            hintText: "Your Email",
            onChanged: (value) {},
          ),
          RoundedPasswordField(
            onChanged: (value) {},
          ),
          RoundedButton(
            text: "SIGNUP",
            press: () {},
          ),
          SizedBox(height: size.height * 0.03),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return loginScreen();
                  },
                ),
              );
            },
          ),
          OrDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SocalIcon(
                iconSrc: "assets/Images/25.png",
                press: () {},
              ),
              SocalIcon(
                iconSrc: "assets/Images/26.png",
                press: () {},
              ),
              SocalIcon(
                iconSrc: "assets/Images/27.png",
                press: () {},
              ),
            ],
          )
        ],
      ),
    );
  }
}
