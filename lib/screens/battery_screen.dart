import 'package:core_tuner/widgets/battery_widget.dart';
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
              const SizedBox(height: 12,)
            ],
          ),
        ),
      ),
    );
  }
}