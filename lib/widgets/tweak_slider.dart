import 'package:core_tuner/colors.dart';
import 'package:core_tuner/widgets/core_snack_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TweakSlider extends StatefulWidget {
  final String title;
  final String storageKey;
  final double min;
  final double max;
  final int divisions;
  final String labelLeft;
  final String labelRight;
  final double defaultValue;
  final Function(int) onAction;

  const TweakSlider({
    super.key,
    required this.title,
    required this.storageKey,
    required this.onAction,
    this.min = 0,
    this.max = 100,
    this.divisions = 100,
    this.labelLeft = "Min",
    this.labelRight = "Max",
    this.defaultValue = 0,
  });

  @override
  State<TweakSlider> createState() => _TweakSliderState();
}

class _TweakSliderState extends State<TweakSlider> {
  double _currentValue = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadValue();
  }

  Future<void> _loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentValue =
            prefs.getInt(widget.storageKey)?.toDouble() ?? widget.defaultValue;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 100);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _currentValue.round().toString(),
                  style: const TextStyle(
                    color: AppColors.royalBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            value: _currentValue,
            onChanged: (double value) {
              setState(() {
                _currentValue = value;
              });
            },
            onChangeEnd: (value) async {
              final int val = value.round();

              final BuildContext currentContext = context;

              try {
                await widget.onAction(val);

                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt(widget.storageKey, val);

                if (!currentContext.mounted) return;

                CoreSnack.show(currentContext, '${widget.title} set to $val');
              } catch (e) {
                if (!currentContext.mounted) return;
                CoreSnack.show(currentContext, 'Error: $e', isError: true);
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.labelLeft,
                style: const TextStyle(color: AppColors.gray, fontSize: 11),
              ),
              Text(
                widget.labelRight,
                style: const TextStyle(color: AppColors.gray, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
