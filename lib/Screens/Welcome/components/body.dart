// import 'package:flutter/material.dart';
// import 'package:inventaris/Screens/Welcome/components/background.dart';
// import 'package:inventaris/constants.dart';

// class Body extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return Background(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Text(
//             "WELCOME TO INNVENTARIS",
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Image.asset(
//             "assets\images\11.png",
//             height: size.height * 0.45,
//           ),
//           RoundedButtom(
//             text: "LOGIN",
//             press: () {},
//           )
//         ],
//       ),
//     );
//   }
// }

// class RoundedButtom extends StatelessWidget {
//   final String text;
//   final Function press;
//   final Color color, textColor;
//   const RoundedButtom({
//     Key key,
//     required this.text,
//     required this.press,
//     required this.color = kPrimaryColor,
//     required this.textColor = Colors.white,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Container(
//       width: size.width * 0.8,
//       child: ClipRRect(
//           borderRadius: BorderRadius.circular(29),
//           child: FlatButton(
//               Padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
//               Color: kPrimaryColor,
//               onPressed: press,
//               child: Text(
//                 text,
//                 style: TextStyle(color: textColor),
//               ))),
//     );
//   }
// }
