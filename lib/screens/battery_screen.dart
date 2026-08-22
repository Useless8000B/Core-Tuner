import 'package:core_tuner/services/battery_services.dart';
import 'package:core_tuner/services/wifi_services.dart';
import 'package:core_tuner/widgets/battery_thermal_widget.dart';
import 'package:core_tuner/widgets/battery_widget.dart';
import 'package:core_tuner/widgets/tweak_switch.dart';
import 'package:flutter/material.dart';

class BatteryScreen extends StatelessWidget {
  const BatteryScreen({
    super.key,
    required this.batteryServices,
    required this.wifiServices,
  });

  final BatteryServices batteryServices;
  final WifiServices wifiServices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              BatteryWidget(batteryServices: batteryServices,),
              const SizedBox(height: 12),
              BatteryThermalWidget(batteryServices: batteryServices),
              const SizedBox(height: 12),
              TweakSwitch(
                title: 'Wi-Fi Scan Throttling',
                storageKey: 'wifi_scan_throttling',
                onAction: (value) async {
                  await wifiServices.setWifiThrottling(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
