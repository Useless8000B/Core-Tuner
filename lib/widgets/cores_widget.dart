import 'package:core_tuner/colors.dart';
import 'package:core_tuner/services/cpu_services.dart';
import 'package:flutter/material.dart';

class CoresWidget extends StatelessWidget {
  const CoresWidget({super.key, required this.cpuServices});
  final CpuServices cpuServices;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<double>>(
      stream: cpuServices.getCpuFrequenciesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final frequencies = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.0,
          ),
          itemCount: frequencies.length,
          itemBuilder: (context, index) {
            return CoreCard(
              key: ValueKey(index),
              index: index,
              freq: frequencies[index],
            );
          },
        );
      },
    );
  }
}

class CoreCard extends StatelessWidget {
  final int index;
  final double freq;

  const CoreCard({super.key, required this.index, required this.freq});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppColors.royalBlue.withValues(alpha: 0.4),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "CORE $index",
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${freq.toStringAsFixed(1)} GHz",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
