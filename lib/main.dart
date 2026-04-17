import 'package:core_tuner/colors.dart';
import 'package:core_tuner/screens/shell_screen.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hasRoot = await SystemService.checkRootAccess();
  SystemService.syncZramState();

  runApp(CoreTuner(hasRoot: hasRoot));
}

class CoreTuner extends StatelessWidget {
  final bool hasRoot;
  const CoreTuner({super.key, required this.hasRoot});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Core Tuner',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.royalBlue,
          brightness: Brightness.dark,
          surface: AppColors.black,
        ),
        scaffoldBackgroundColor: AppColors.black,

        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.black,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        navigationDrawerTheme: NavigationDrawerThemeData(
          backgroundColor: AppColors.lightBlack,
        ),
      ),
      home: const ShellScreen(),
    );
  }
}
