import 'package:core_tuner/services/cpu_services.dart';
import 'package:core_tuner/widgets/cores_widget.dart';
import 'package:core_tuner/widgets/scaling_governor_widget.dart';
import 'package:core_tuner/widgets/thermal_widget.dart';
import 'package:flutter/material.dart';

class CpuScreen extends StatelessWidget {
  const CpuScreen({super.key, required this.cpuServices});
  final CpuServices cpuServices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ThermalWidget(cpuServices: cpuServices),
              const SizedBox(height: 20),
              ScalingGovernorWidget(cpuServices: cpuServices),
              const SizedBox(height: 20),
              CoresWidget(cpuServices: cpuServices),
            ],
          ),
        ),
      ),
    );
  }
}
