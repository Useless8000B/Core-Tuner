import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/battery_services.dart';
import 'package:core_tuner/src/rust/models/battery.dart';
import 'package:flutter/material.dart';

class BatteryWidget extends StatelessWidget {
  const BatteryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BatteryServices batteryServices = BatteryServices();

    return RepaintBoundary(
      child: StreamBuilder<Battery>(
        stream: batteryServices.getBatteryStream(),
        builder: (context, snapshot) {
          final data = snapshot.data;

          double level = data?.level.toDouble() ?? 0.0;
          double current = data?.current ?? 0.0;
          double voltage = data?.voltage ?? 0.0;
          bool isCharging = data?.isCharging ?? false;

          Color accentColor = isCharging
              ? AppColors.green
              : AppColors.royalBlue;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.lightBlack,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.01),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -10,
                  right: -10,
                  child: Opacity(
                    opacity: 0.07,
                    child: Icon(
                      isCharging ? Icons.bolt : Icons.battery_std,
                      color: AppColors.gray,
                      size: 100,
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BATTERY STATUS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppColors.gray.withValues(alpha: 0.5),
                      ),
                    ),

                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${level.toInt()}",
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 60,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "%",
                            style: TextStyle(
                              color: AppColors.gray.withValues(alpha: 0.5),
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(width: 8),

                          if (isCharging)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "CHR",
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                          const Spacer(),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${current.abs()} mA",
                                style: TextStyle(
                                  color: isCharging
                                      ? AppColors.green
                                      : AppColors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isCharging ? "INPUT" : "DRAIN",
                                style: TextStyle(
                                  color: AppColors.gray.withValues(alpha: 0.4),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$voltage V",
                                style: TextStyle(
                                  color: AppColors.gray.withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
