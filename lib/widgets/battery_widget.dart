import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:flutter/material.dart';

class BatteryWidget extends StatelessWidget {
  const BatteryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: SystemService.getBatteryStream(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {
          'level': 0.0,
          'voltage': '0.0',
          'current': 0,
          'isCharging': false
        };

        double level = data['level'];
        int current = data['current'];
        String voltage = data['voltage'];
        bool isCharging = data['isCharging'];

        double progress = (level / 100).clamp(0.0, 1.0);
        Color accentColor = isCharging ? Colors.greenAccent : AppColors.royalBlue;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "CHR",
                                style: TextStyle(
                                  color: Colors.greenAccent,
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
                                color: isCharging ? Colors.greenAccent : Colors.redAccent,
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

                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${level.toInt()}%",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray.withValues(alpha: 0.5),
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