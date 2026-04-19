import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:flutter/material.dart';

class ThermalWidget extends StatelessWidget {
  const ThermalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: SystemService.getTemperatureStream(),
      builder: (context, snapshot) {
        double temp = snapshot.data ?? 0.0;
        double progress = ((temp - 20) / (80 - 20)).clamp(0.0, 1.0);

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
                    Icons.thermostat,
                    color: AppColors.gray,
                    size: 80,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "THERMAL INDEX",
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
                        temp > 0 ? temp.toStringAsFixed(0) : "--",
                        style: TextStyle(
                          color: AppColors.royalBlue,
                          fontSize: 68,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "°C",
                        style: TextStyle(
                          color: AppColors.royalBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                                color: AppColors.royalBlue,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.royalBlue.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        temp > 50 ? "HIGH" : "OPTIMAL",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: temp > 50
                              ? Colors.orange
                              : AppColors.royalBlue,
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
