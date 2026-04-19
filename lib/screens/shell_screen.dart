import 'package:core_tuner/screens/storage_screen.dart';
import 'package:core_tuner/widgets/appbar_widget.dart';
import 'package:core_tuner/navigation/drawer_navigator.dart';
import 'package:core_tuner/screens/battery_screen.dart';
import 'package:core_tuner/screens/cpu_screen.dart';
import 'package:core_tuner/screens/ram_screen.dart';
import 'package:flutter/material.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {'title': 'Dashboard', 'screen': StorageScreen()},
    {'title': 'CPU', 'screen': const CpuScreen()},
    {'title': 'RAM', 'screen': const RamScreen()},
    {'title': 'Battery', 'screen': const BatteryScreen()}
  ];

  void _navigate(int index) {
    if (index == _currentIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentIndex = index;
        });
      }
    });

  }
  void navigateFromDrawer(int index) {
    Navigator.pop(context);
    _navigate(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarComponent(title: _pages[_currentIndex]['title']),
      drawer: DrawerNavigator(
        onTap: navigateFromDrawer,
        currentIndex: _currentIndex,
      ),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages.map((e) => e['screen'] as Widget).toList(),),
      ),
    );
  }
}