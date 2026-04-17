import 'package:core_tuner/widgets/ram_widget.dart';
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
            ],
          ),
        ),
      ),
    );
  }
}
