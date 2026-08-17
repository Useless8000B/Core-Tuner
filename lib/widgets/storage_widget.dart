import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/storage_services.dart';
import 'package:core_tuner/src/rust/models/storage.dart';
import 'package:flutter/material.dart';

class StorageWidget extends StatelessWidget {
  const StorageWidget({super.key, required this.storageServices});
  final StorageServices storageServices;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Storage>(
      stream: storageServices.getStorageStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final storage = snapshot.data!;

        final double usedGb = storage.used.toDouble() / (1024 * 1024 * 1024);
        final double totalGb = storage.total.toDouble() / (1024 * 1024 * 1024);
        final String usedStr = usedGb.toStringAsFixed(1);
        final String totalStr = "${totalGb.toStringAsFixed(0)} GB";

        double progressFactor = totalGb > 0 ? (usedGb / totalGb) : 0.0;
        if (progressFactor > 1.0) progressFactor = 1.0;
        if (progressFactor < 0.0) progressFactor = 0.0;

        final String percentStr =
            "${(progressFactor * 100).toStringAsFixed(0)}%";

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
                        usedStr,
                        style: TextStyle(
                          color: AppColors.royalBlue,
                          fontSize: 68,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        " / $totalStr",
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
                            widthFactor: progressFactor,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.royalBlue,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.royalBlue.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
