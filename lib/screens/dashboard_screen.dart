import 'package:core_tuner/services/system_services.dart';
import 'package:core_tuner/widgets/core_snack_widget.dart';
import 'package:core_tuner/widgets/storage_widget.dart';
import 'package:core_tuner/widgets/tweak_button.dart';
import 'package:core_tuner/widgets/tweak_switch.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              StorageWidget(),
              const SizedBox(height: 20),
              TweakButton(
                title: 'Wipe Dalvik Cache',
                onAction: SystemService.clearDalvik,
              ),
              TweakSwitch(
                title: 'Wi-Fi Scan Throttling',
                storageKey: 'wifi_scan_throttling',
                onAction: (value) async {
                  try {
                    await SystemService.setWifiThrottling(value);

                    if (context.mounted) {
                      CoreSnack.show(context, "Wi-Fi throttling ${value ? 'Activated' : 'Deactivated'}");
                    }
                  } catch (e) {
                    if (context.mounted) {
                      CoreSnack.show(context, "Error applying: $e", isError: true);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
