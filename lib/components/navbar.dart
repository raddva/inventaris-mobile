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
  List<SMIBool> riveIconInputs = [];
  List<StateMachineController?> controllers = [];
  int selectedNavIndex = 0;
  List<String> pages = ["Home", "Search", "Inventory", "Profile"];

  void animateTheIcon(int index) {
    if (index < riveIconInputs.length) {
      riveIconInputs[index].change(true);
      Future.delayed(Duration(seconds: 1), () {
        riveIconInputs[index].change(false);
      });
    } else {
      print("Invalid index or SMIBool not initialized for index: $index");
    }
  }

  void riveOnInit(Artboard artboard, {required String stateMachineName}) {
    final controller =
        StateMachineController.fromArtboard(artboard, stateMachineName);
    if (controller != null) {
      artboard.addController(controller);
      controllers.add(controller);

      final smiBool = controller.findInput<bool>('active') as SMIBool?;
      if (smiBool != null) {
        riveIconInputs.add(smiBool);
      } else {
        print("SMIBool 'active' not found in state machine: $stateMachineName");
      }
    } else {
      print(
          "StateMachineController not initialized for state machine: $stateMachineName");
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(pages[selectedNavIndex]),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.all(24),
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
            children: List.generate(bottomNavItems.length, (index) {
              final riveIcon = bottomNavItems[index].rive;
              return GestureDetector(
                onTap: () {
                  animateTheIcon(index);
                  setState(() {
                    selectedNavIndex = index;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBar(
                      isActive: selectedNavIndex == index,
                    ),
                    SizedBox(
                      height: 36,
                      width: 36,
                      child: Opacity(
                        opacity: selectedNavIndex == index ? 1 : 0.5,
                        child: RiveAnimation.asset(
                          riveIcon.src,
                          artboard: riveIcon.artboard,
                          onInit: (artboard) {
                            riveOnInit(artboard,
                                stateMachineName: riveIcon.stateMachineName);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({super.key, required this.isActive});

  final bool isActive;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 2),
      height: 4,
      width: isActive ? 20 : 0,
      decoration: BoxDecoration(
          color: Color(0xFF81B4FF),
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }
}
