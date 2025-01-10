// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:inventaris/models/nav_item_model.dart';
import 'package:rive/rive.dart';

const Color navBgColor = Color(0xFF17203A);

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 56,
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: navBgColor.withOpacity(0.3),
            borderRadius: BorderRadius.all(Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: navBgColor.withOpacity(0.3),
                offset: Offset(0, 20),
                blurRadius: 20,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
                bottomNavItems.length,
                (index) => SizedBox(
                      height: 36,
                      width: 36,
                      child: RiveAnimation.asset(
                        bottomNavItems[index].rive.src,
                        artboard: bottomNavItems[index].rive.artboard,
                      ),
                    )),
          ),
        ),
      ),
    );
  }
}
