import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:flutter/material.dart';
import 'package:storage_space/storage_space.dart';

class StorageWidget extends StatelessWidget {
  const StorageWidget({super.key});

  double parseGbString(String? value) {
    if (value == null) return 0.0;
    return double.tryParse(value.replaceAll(' GB', '').trim()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageSpace>(
      stream: SystemService.getStorageStream(),
      builder: (context, snapshot) {
        final storage = snapshot.data;
        final double totalGb = parseGbString(storage?.totalSize.toString());
        final double freeGb = parseGbString(storage?.freeSize.toString());
        final double usedGb = totalGb - freeGb;
        final double progress = (totalGb > 0)
            ? (usedGb / totalGb).clamp(0.0, 1.0)
            : 0.0;

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
                        storage != null ? usedGb.toStringAsFixed(1) : "--",
                        style: TextStyle(
                          color: AppColors.royalBlue,
                          fontSize: 68,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SpaceGrotesk',
                        ),
                      ),
                      Text(
                        storage != null
                            ? " / ${totalGb.toStringAsFixed(0)} GB"
                            : " / -- GB",
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
                                color: storage != null
                                    ? AppColors.royalBlue
                                    : AppColors.gray.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: storage != null
                                    ? [
                                        BoxShadow(
                                          color: AppColors.royalBlue.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 6,
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
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
