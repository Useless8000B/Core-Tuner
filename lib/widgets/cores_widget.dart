import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/system_services.dart';
import 'package:flutter/material.dart';

class CoresWidget extends StatelessWidget {
  const CoresWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<double>>(
      stream: SystemService.getCpuFrequenciesStream(),
      builder: (context, snapshot) {
        List<double> freqs = snapshot.data ?? List.generate(8, (_) => 0.0);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            double maxForThisCore = (index < 4) ? 1.9 : 2.4;
            return buildCoreCard("Core $index", freqs[index], maxForThisCore);
          },
        );
      },
    );
  }

  Widget buildCoreCard(String label, double freq, double maxFreq) {
    double progress = (freq / maxFreq).clamp(0.0, 1.0);
    double percentage = progress * 100;
    bool isHighLoad = progress > 0.9;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isHighLoad
                ? Colors.redAccent
                : AppColors.royalBlue.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "${freq.toStringAsFixed(1)} GHz",
                style: TextStyle(
                  color: isHighLoad ? Colors.redAccent : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              Text(
                "${percentage.toInt()}%",
                style: TextStyle(
                  color: isHighLoad
                      ? Colors.redAccent.withValues(alpha: 0.7)
                      : Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            color: isHighLoad ? Colors.redAccent : AppColors.royalBlue,
            minHeight: 2,
          ),
        ],
      ),
    );
  }
}
