import 'dart:io';

import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:core_tuner/widgets/core_snack_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwappinessWidget extends StatefulWidget {
  const SwappinessWidget({super.key});

  @override
  State<SwappinessWidget> createState() => _SwappinessWidgetState();
}

class _SwappinessWidgetState extends State<SwappinessWidget> {
  double currentValue = 60;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentValue();
  }

  Future<void> _fetchCurrentValue() async {
    try {
      final result = await Process.run('su', [
        '-c',
        'cat /proc/sys/vm/swappiness',
      ]);
      if (result.exitCode == 0) {
        final val = double.tryParse(result.stdout.toString().trim());
        if (val != null) {
          setState(() {
            currentValue = val;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Swappiness',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  currentValue.round().toString(),
                  style: const TextStyle(
                    color: AppColors.royalBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Slider(
            min: 0,
            max: 100,
            divisions: 100,
            value: currentValue,
            onChanged: (double value) {
              setState(() {
                currentValue = value;
              });
            },
            onChangeEnd: (value) async {
              final int val = value.round();
              await SystemService.applySwappiness(val);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('swappiness_value', val);

              if (!context.mounted) return;

              CoreSnack.show(context, 'Swappiness set to $val');
            },
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performance",
                style: TextStyle(color: AppColors.gray, fontSize: 11),
              ),
              Text(
                "Multitasking",
                style: TextStyle(color: AppColors.gray, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
