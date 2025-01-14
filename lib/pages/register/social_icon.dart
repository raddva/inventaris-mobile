import 'package:flutter/material.dart';
import 'package:inventaris/constants.dart';

class SocalIcon extends StatelessWidget {
  final String iconSrc;
  final Function press;
  const SocalIcon({
    super.key,
    required this.iconSrc,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: kPrimaryColor,
          ),
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          iconSrc,
          height: 20,
          width: 20,
        ),
      ),
    );
  }
}
