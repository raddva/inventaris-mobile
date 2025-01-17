import 'rive_model.dart';

class NavItemModel {
  final String title;
  final RiveModel rive;

  NavItemModel({required this.title, required this.rive});
}

List<NavItemModel> bottomNavItems = [
  NavItemModel(
    title: "Home",
    rive: RiveModel(
        src: "assets/RiveAssets/animated-icons.riv",
        artboard: "HOME",
        stateMachineName: "HOME_interactivity"),
  ),
  // NavItemModel(
  //   title: "Search",
  //   rive: RiveModel(
  //       src: "assets/RiveAssets/animated-icons.riv",
  //       artboard: "SEARCH",
  //       stateMachineName: "SEARCH_Interactivity"),
  // ),
  NavItemModel(
    title: "Inventory",
    rive: RiveModel(
        src: "assets/RiveAssets/animated-icons.riv",
        artboard: "REFRESH/RELOAD",
        stateMachineName: "RELOAD_Interactivity"),
  ),
  NavItemModel(
    title: "Settings",
    rive: RiveModel(
        src: "assets/RiveAssets/animated-icons.riv",
        artboard: "SETTINGS",
        stateMachineName: "SETTINGS_Interactivity"),
  ),
  NavItemModel(
    title: "Profile",
    rive: RiveModel(
        src: "assets/RiveAssets/animated-icons.riv",
        artboard: "USER",
        stateMachineName: "USER_Interactivity"),
  ),
];
