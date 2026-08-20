import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/battery_services.dart';
import 'package:flutter/material.dart';

class BatteryThermalWidget extends StatelessWidget {
  const BatteryThermalWidget({super.key, required this.batteryServices});
  final BatteryServices batteryServices;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: StreamBuilder<double>(
        stream: batteryServices.getBatteryTemperatureStream(),
        builder: (context, snapshot) {
          double temp = snapshot.data ?? 0.0;

          Color statusColor = AppColors.royalBlue;
          String statusText = "OPTIMAL";

          if (temp >= 40) {
            statusColor = AppColors.orange;
            statusText = "WARM";
          }

          if (temp >= 45) {
            statusColor = AppColors.red;
            statusText = "CRITICAL";
          }

          return Container(
            padding: const EdgeInsets.all(24),
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
                  top: -5,
                  right: -5,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      Icons.battery_std,
                      color: AppColors.gray,
                      size: 80,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BATTERY TEMPERATURE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppColors.gray.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          temp > 0 ? temp.toStringAsFixed(1) : "--",
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 68,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "°C",
                          style: TextStyle(color: statusColor, fontSize: 24),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 1,
                        ),
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
