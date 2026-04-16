import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:flutter/material.dart';

class ScalingGovernorWidget extends StatelessWidget {
  const ScalingGovernorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SCALING GOVERNOR",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.gray.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          DropdownMenu<String>(
            initialSelection: 'schedutil',
            expandedInsets: EdgeInsets.zero,
            inputDecorationTheme: const InputDecorationTheme(
              filled: false,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'SpaceGrotesk',
            ),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(AppColors.lightBlack),
            ),
            onSelected: (String? value) async {
              if (value != null) {
                await SystemService.setGlobalGovernor(value);
                print("Governor aplicado: $value");
              }
            },
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                value: 'performance',
                label: 'performance',
                leadingIcon: Icon(
                  Icons.bolt,
                  color: Colors.orangeAccent,
                  size: 18,
                ),
              ),
              DropdownMenuEntry(
                value: 'schedutil',
                label: 'schedutil',
                leadingIcon: Icon(
                  Icons.auto_awesome,
                  color: Colors.blueAccent,
                  size: 18,
                ),
              ),
              DropdownMenuEntry(
                value: 'powersave',
                label: 'powersave',
                leadingIcon: Icon(
                  Icons.eco,
                  color: Colors.greenAccent,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
