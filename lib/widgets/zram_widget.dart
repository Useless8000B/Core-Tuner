import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/memory_services.dart';
import 'package:core_tuner/src/rust/models/zram.dart';
import 'package:flutter/material.dart';

class ZramWidget extends StatelessWidget {
  const ZramWidget({super.key, required this.memoryServices});
  final MemoryServices memoryServices;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: StreamBuilder<Zram>(
        stream: memoryServices.getZramStream(),
        builder: (context, snapshot) {
          final data = snapshot.data;

          double origin = data?.origin ?? 0.0;
          double total = data?.total ?? 0.0;
          double ratio = data?.ratio ?? 0.0;

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
                      Icons.swap_calls,
                      color: AppColors.gray,
                      size: 80,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ZRAM / SWAP USAGE",
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
                          origin > 1024
                              ? (origin / 1024).toStringAsFixed(1)
                              : origin.toStringAsFixed(0),
                          style: TextStyle(
                            color: AppColors.purple,
                            fontSize: 68,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          origin > 1024 ? " GB" : " MB",
                          style: TextStyle(
                            color: AppColors.gray.withValues(alpha: 0.5),
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${ratio.toStringAsFixed(2)}x",
                              style: const TextStyle(
                                color: AppColors.purple,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "COMPRESSION",
                              style: TextStyle(
                                color: AppColors.gray.withValues(alpha: 0.4),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "LIMIT: ${total.toStringAsFixed(0)}GB",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray.withValues(alpha: 0.6),
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
