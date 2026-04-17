import 'package:core_tuner/colors.dart';
import 'package:core_tuner/widgets/core_snack_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TweakSwitch extends StatefulWidget {
  final String title;
  final String storageKey;
  final Function(bool) onAction;

  const TweakSwitch({
    super.key,
    required this.title,
    required this.storageKey,
    required this.onAction,
  });

  @override
  State<TweakSwitch> createState() => _TweakSwitchState();
}

class _TweakSwitchState extends State<TweakSwitch> {
  bool _isEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEnabled = prefs.getBool(widget.storageKey) ?? false;
      _isLoading = false;
    });
  }

  Future<void> _toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final bool originalValue = _isEnabled;

    setState(() => _isEnabled = value);

    try {
      await widget.onAction(value);

      await prefs.setBool(widget.storageKey, value);
      
      if (mounted) {
        CoreSnack.show(context, "${widget.title} aplicado!");
      }
    } catch (e) {
      setState(() => _isEnabled = originalValue);
      
      await prefs.setBool(widget.storageKey, originalValue);

      if (mounted) {
        CoreSnack.show(context, "Erro: $e", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 80);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isEnabled,
            activeThumbColor: AppColors.royalBlue,
            onChanged: _toggle,
          ),
        ],
      ),
    );
  }
}
