import 'package:core_tuner/services/kernel_services.dart';
import 'package:core_tuner/services/memory_services.dart';
import 'package:core_tuner/widgets/ram_widget.dart';
import 'package:core_tuner/widgets/tweak_slider.dart';
import 'package:core_tuner/widgets/zram_widget.dart';
import 'package:flutter/material.dart';

class RamScreen extends StatefulWidget {
  const RamScreen({
    super.key,
    required this.kernelServices,
    required this.memoryServices,
  });

  final KernelServices kernelServices;
  final MemoryServices memoryServices;

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
              RamWidget(memoryServices: widget.memoryServices),
              const SizedBox(height: 20),
              ZramWidget(memoryServices: widget.memoryServices),
              const SizedBox(height: 20),
              TweakSlider(
                title: 'Low Memory Killer',
                labelLeft: 'Multitasking',
                labelRight: 'Performance',
                min: 0,
                max: 3,
                storageKey: 'low_memory_killer',
                onAction: (value) async {
                  await widget.kernelServices.applyLmkProfile(value);
                },

                kernelServices: widget.kernelServices,
              ),
              TweakSlider(
                title: 'Swappiness',
                storageKey: 'swappiness',
                labelLeft: 'Performance',
                labelRight: 'Multitasking',
                onAction: (value) async {
                  await widget.kernelServices.applySwappiness(value);
                },

                kernelServices: widget.kernelServices,
              ),
              TweakSlider(
                title: 'Vm Dirty Ratio',
                storageKey: 'vm_dirty_ratio',
                labelLeft: 'Integrity',
                labelRight: 'Performance',
                onAction: (value) async {
                  await widget.kernelServices.applyVmDirtyRatio(value);
                },

                kernelServices: widget.kernelServices,
              ),
              TweakSlider(
                title: 'Vm Dirty Background Ratio',
                storageKey: 'vm_dirty_background_ratio',
                labelLeft: 'Responsiveness',
                labelRight: 'Throughput',
                onAction: (value) async {
                  await widget.kernelServices.applyVmDirtyBackgroundRatio(
                    value,
                  );
                },

                kernelServices: widget.kernelServices,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
