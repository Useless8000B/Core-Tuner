import 'package:core_tuner/services/system_services.dart';
import 'package:core_tuner/widgets/ram_widget.dart';
import 'package:core_tuner/widgets/tweak_slider.dart';
import 'package:core_tuner/widgets/tweak_switch.dart';
import 'package:core_tuner/widgets/zram_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RamScreen extends StatefulWidget {
  const RamScreen({super.key});

  @override
  State<RamScreen> createState() => _RamScreenState();
}

class _RamScreenState extends State<RamScreen> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _syncSystem();
  }

  bool _isInitialSync = true;

  Future<void> _syncSystem() async {
    if (!_isInitialSync) return;

    await SystemService.syncZramState();
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        isLoading = false;
        _isInitialSync = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const RamWidget(),
              const SizedBox(height: 20),
              const ZramWidget(),
              const SizedBox(height: 20),
              TweakSwitch(
                title: 'ZRAM Swap',
                storageKey: 'zram_swap',
                checkStatus: () async {
                  final prefs = await SharedPreferences.getInstance();
                  return prefs.getBool('zram_swap') ?? false;
                },
                onAction: (value) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('zram_swap', value);
                  await SystemService.applyZramTweak(value);
                },
              ),
              const SizedBox(height: 20),
              TweakSlider(
                title: 'Swappiness',
                storageKey: 'swappiness',
                labelLeft: 'performance',
                labelRight: 'Multitasking',
                onAction: (value) {
                  SystemService.applySwappiness(value);
                },
              ),
              TweakSlider(
                title: 'Vm Dirty Ratio',
                storageKey: 'vm_dirty_ratio',
                labelLeft: 'Integrity',
                labelRight: 'Performance',
                onAction: (value) async {
                  await SystemService.applyDirtyRatio(value);
                },
              ),
              TweakSlider(
                title: 'Aggressive LMK',
                storageKey: 'low_memory_killer',
                min: 0,
                max: 3,
                onAction: (value) async {
                  await SystemService.applyLmkProfile(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
