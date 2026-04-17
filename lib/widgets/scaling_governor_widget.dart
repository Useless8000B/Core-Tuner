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
                try {
                  await SystemService.setGlobalGovernor(value);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Governor set to $value", style: TextStyle(color: AppColors.white),),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppColors.lightBlack,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Root access denied or system error.",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
            },
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                value: 'performance',
                label: 'performance',
                leadingIcon: Icon(Icons.bolt, color: Colors.orangeAccent, size: 18),
              ),
              DropdownMenuEntry(
                value: 'schedutil',
                label: 'schedutil',
                leadingIcon: Icon(Icons.auto_awesome, color: Colors.blueAccent, size: 18),
              ),
              DropdownMenuEntry(
                value: 'powersave',
                label: 'powersave',
                leadingIcon: Icon(Icons.eco, color: Colors.greenAccent, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}