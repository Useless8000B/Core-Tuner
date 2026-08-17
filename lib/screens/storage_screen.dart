import 'package:core_tuner/services/storage_services.dart';
import 'package:core_tuner/widgets/storage_widget.dart';
import 'package:core_tuner/widgets/tweak_button.dart';
import 'package:flutter/material.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key, required this.storageServices});
  final StorageServices storageServices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              StorageWidget(storageServices: storageServices,),
              const SizedBox(height: 20),
              TweakButton(
                title: 'Run FSTRIM',
                onAction: () => storageServices.runFstrim(),
              ),
              TweakButton(
                title: 'Clear logs',
                onAction: () => storageServices.runClearLogs(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
