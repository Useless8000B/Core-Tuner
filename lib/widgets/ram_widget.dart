import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:flutter/material.dart';

class RamWidget extends StatelessWidget {
  const RamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, double>>(
      stream: SystemService.getRamStream(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'used': 0.0, 'total': 8.0};
        double used = data['used']!;
        double total = data['total']!;
        
        double progress = (total > 0) ? (used / total).clamp(0.0, 1.0) : 0.0;

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
                    Icons.memory,
                    color: AppColors.gray,
                    size: 80,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MEMORY USAGE",
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
                        used > 0 ? used.toStringAsFixed(1) : "--",
                        style: TextStyle(
                          color: AppColors.royalBlue,
                          fontSize: 68,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SpaceGrotesk',
                        ),
                      ),
                      Text(
                        " / ${total.toStringAsFixed(0)} GB",
                        style: TextStyle(
                          color: AppColors.gray.withValues(alpha: 0.5),
                          fontSize: 20,
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
                                    color: AppColors.royalBlue.withValues(alpha: 0.5),
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
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: progress > 0.8 ? Colors.orange : AppColors.royalBlue,
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