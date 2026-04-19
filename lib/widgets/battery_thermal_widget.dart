import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:flutter/material.dart';

class BatteryThermalWidget extends StatelessWidget {
  const BatteryThermalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: SystemService.getBatteryTempStream(),
      builder: (context, snapshot) {
        double temp = snapshot.data ?? 0.0;

        Color statusColor = AppColors.royalBlue;
        String statusText = "OPTIMAL";

        if (temp >= 40) {
          statusColor = Colors.orangeAccent;
          statusText = "WARM";
        }
        if (temp >= 45) {
          statusColor = Colors.redAccent;
          statusText = "CRITICAL";
        }

        double progress = ((temp - 15) / (55 - 15)).clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.lightBlack,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.01)),
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
                          color: statusColor, // Cor dinâmica!
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
                  Row(
                    children: [
                      Expanded(
                        child: _ProgressBar(
                          progress: progress,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _ProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}