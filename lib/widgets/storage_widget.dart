import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:flutter/material.dart';

class StorageWidget extends StatelessWidget {
  const StorageWidget({super.key});

  double parseValue(String? value) {
    if (value == null || value == "--") return 0.0;
    String cleanValue = value
        .replaceAll(RegExp(r'[^0-9.,]'), '')
        .replaceFirst(',', '.');
    return double.tryParse(cleanValue) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, String>>(
      stream: SystemService.getStorageStream(),
      builder: (context, snapshot) {
        final storage = snapshot.data;

        final String usedStr = storage?['used'] ?? "--";
        final String percentStr = storage?['percent'] ?? "0%";

        final double progress = (parseValue(percentStr) / 100).clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.lightBlack,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -5,
                right: -5,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.storage_rounded,
                    color: AppColors.gray,
                    size: 80,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "INTERNAL STORAGE",
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
                        usedStr.replaceAll(
                          RegExp(r'[a-zA-Z]'),
                          '',
                        ),
                        style: TextStyle(
                          color: AppColors.royalBlue,
                          fontSize: 68,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SpaceGrotesk',
                        ),
                      ),
                      Text(
                        " / ${storage?['total'] ?? "--"}",
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
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: storage != null
                                    ? AppColors.royalBlue
                                    : AppColors.gray.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: storage != null
                                    ? [
                                        BoxShadow(
                                          color: AppColors.royalBlue.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        percentStr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
