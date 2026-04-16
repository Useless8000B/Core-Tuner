import 'package:flutter/material.dart';

class DrawerNavigator extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const DrawerNavigator({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      children: [
        const NavigationDrawerDestination(icon: Icon(Icons.dashboard), label: Text("Dashboard")),
        const NavigationDrawerDestination(icon: Icon(Icons.memory), label: Text("CPU")),
        const NavigationDrawerDestination(icon: Icon(Icons.bolt), label: Text("RAM")),
        const NavigationDrawerDestination(icon: Icon(Icons.battery_charging_full), label: Text("Battery")),
        const NavigationDrawerDestination(icon: Icon(Icons.build), label: Text("Kernel")),
      ],
    );
  }
}