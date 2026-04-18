import 'package:core_tuner/colors.dart';
import 'package:core_tuner/screens/shell_screen.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemService.applySavedTweaks();

  bool hasRoot = await SystemService.checkRootAccess();

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

        sliderTheme: SliderThemeData(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          activeTrackColor: AppColors.royalBlue,
          inactiveTrackColor: AppColors.white.withValues(alpha: 0.1),
          thumbColor: AppColors.royalBlue,
          valueIndicatorColor: AppColors.royalBlue,
        ),
      ),
      home: const ShellScreen(),
    );
  }
}
