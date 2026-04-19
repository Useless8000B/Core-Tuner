import 'package:core_tuner/services/system_services.dart';
import 'package:core_tuner/widgets/storage_widget.dart';
import 'package:core_tuner/widgets/tweak_button.dart';
import 'package:flutter/material.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

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
              TweakButton(
                title: 'Run FSTRIM',
                onAction: () => SystemService.runStorageTrim(),
              ),
              TweakButton(
                title: 'Clear logs',
                onAction: () => SystemService.clearSystemLogs(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
