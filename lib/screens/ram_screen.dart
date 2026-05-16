import 'package:core_tuner/services/system_services_rust.dart';
import 'package:core_tuner/widgets/ram_widget.dart';
import 'package:core_tuner/widgets/tweak_slider.dart';
import 'package:core_tuner/widgets/zram_widget.dart';
import 'package:flutter/material.dart';

class RamScreen extends StatefulWidget {
  const RamScreen({super.key});

  @override
  State<RamScreen> createState() => _RamScreenState();
}

class _RamScreenState extends State<RamScreen> {
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
              TweakSlider(
                title: 'Swappiness',
                storageKey: 'swappiness',
                labelLeft: 'Performance',
                labelRight: 'Multitasking',
                onAction: (value) async {
                  await SystemServicesRust.applySwappiness(value);
                },
              ),
              TweakSlider(
                title: 'Vm Dirty Ratio',
                storageKey: 'vm_dirty_ratio',
                labelLeft: 'Integrity',
                labelRight: 'Performance',
                onAction: (value) async {
                  await SystemServicesRust.applyVmDirtyRatio(value);
                },
              ),
              TweakSlider(
                title: 'Aggressive LMK',
                storageKey: 'low_memory_killer',
                min: 0,
                max: 3,
                onAction: (value) async {
                  // TODO Implement logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
