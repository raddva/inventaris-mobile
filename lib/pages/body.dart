import 'package:flutter/material.dart';
import 'package:inventaris/components/already_have_an_account_acheck.dart';
import 'package:inventaris/components/rounded_button.dart';
import 'package:inventaris/components/rounded_input_field.dart';
import 'package:inventaris/components/rounded_password_field.dart';
import 'package:inventaris/components/text_field_container.dart';
import 'package:inventaris/constants.dart';
import 'package:inventaris/pages/background.dart';
import 'package:inventaris/pages/register.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Body extends StatelessWidget {
  const Body({
    super.key, required Column child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "LOGIN",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: size.height * 0.03),
          Image.asset(
            "assets/Images/login.png",
            height: size.height * 0.35,
          ),
          SizedBox(height: size.height * 0.03),
          RoudedInputField(
            hintText: "Your Email",
            onChanged: (value) {},
          ),
          RoundedPasswordField(
            onChanged: (value) {},
          ),
          RoundedButton(
            text: "LOGIN",
            press: () {},
          ),
          SizedBox(height: size.height * 0.03),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Register();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
