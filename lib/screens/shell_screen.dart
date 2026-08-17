import 'package:core_tuner/screens/storage_screen.dart';
import 'package:core_tuner/services/battery_services.dart';
import 'package:core_tuner/services/cpu_services.dart';
import 'package:core_tuner/services/kernel_services.dart';
import 'package:core_tuner/services/memory_services.dart';
import 'package:core_tuner/services/storage_services.dart';
import 'package:core_tuner/services/wifi_services.dart';
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

  final BatteryServices batteryServices = BatteryServices();
  final WifiServices wifiServices = WifiServices();
  final KernelServices kernelServices = KernelServices();
  final StorageServices storageServices = StorageServices();
  final CpuServices cpuServices = CpuServices();
  final MemoryServices memoryServices = MemoryServices();

  late final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Dashboard',
      'screen': StorageScreen(storageServices: storageServices),
    },
    {'title': 'CPU', 'screen': CpuScreen(cpuServices: cpuServices)},
    {
      'title': 'RAM',
      'screen': RamScreen(
        kernelServices: kernelServices,
        memoryServices: memoryServices,
      ),
    },
    {
      'title': 'Battery',
      'screen': BatteryScreen(
        batteryServices: batteryServices,
        wifiServices: wifiServices,
      ),
    },
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
        child: IndexedStack(
          index: _currentIndex,
          children: _pages.map((e) => e['screen'] as Widget).toList(),
        ),
      ),
    );
  }
}
