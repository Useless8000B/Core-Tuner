import 'package:core_tuner/services/system_services.dart';
import 'package:core_tuner/widgets/core_snack_widget.dart';
import 'package:core_tuner/widgets/ram_widget.dart';
import 'package:core_tuner/widgets/tweak_switch.dart';
import 'package:core_tuner/widgets/zram_widget.dart';
import 'package:flutter/material.dart';

class RamScreen extends StatelessWidget {
  const RamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsGeometry.all(20),
          child: Column(
            children: [
              RamWidget(),
              const SizedBox(height: 20),
              ZramWidget(),
              const SizedBox(height: 20),
              TweakSwitch(
                title: 'ZRAM Swap',
                storageKey: 'zram_swap',
                checkStatus: () => SystemService.isZramActive(),
                onAction: (value) async {
                  try {
                    await SystemService.applyZramTweak(value);
                    if (context.mounted) {
                      CoreSnack.show(
                        context,
                        "ZRAM Swap ${value ? 'Activated' : 'Deactivated'}",
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      CoreSnack.show(
                        context,
                        "Error applying: $e",
                        isError: true,
                      );
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
