import 'package:core_tuner/widgets/battery_thermal_widget.dart';
import 'package:core_tuner/widgets/battery_widget.dart';
import 'package:core_tuner/widgets/tweak_slider.dart';
import 'package:core_tuner/widgets/tweak_switch.dart';
import 'package:flutter/material.dart';

class BatteryScreen extends StatelessWidget {
  const BatteryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              BatteryWidget(),
              const SizedBox(height: 12),
              BatteryThermalWidget(),
              const SizedBox(height: 12),
              TweakSwitch(
                title: 'Wi-Fi Scan Throttling',
                storageKey: 'wifi_scan_throttling',
                onAction: (value) async {
                  // TODO implement logic
                },
              ),
              TweakSwitch(
                title: 'Battery Idle Mode',
                storageKey: 'battery_idle_mode',
                onAction: (value) async {
                  // TODO implement logic
                },
              ),
              TweakSlider(
                title: 'Battery Charge Limit',
                storageKey: 'charge_limit',
                onAction: (value) async {
                  // TODO implement logic
                },
                min: 50,
                max: 100,
                defaultValue: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
