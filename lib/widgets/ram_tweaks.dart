import 'package:core_tuner/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RamTweaks extends StatefulWidget {
  const RamTweaks({super.key});

  @override
  State<RamTweaks> createState() => _RamTweaksState();
}

class _RamTweaksState extends State<RamTweaks> {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  bool _lmkEnabled = false;
  bool _ksmEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _lmkEnabled = _prefs.getBool('lmk_enabled') ?? false;
      _ksmEnabled = _prefs.getBool('ksm_enabled') ?? false;
      _isInitialized = true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        _buildTweakSwitch(
          title: 'Low Memory Killer',
          value: _lmkEnabled,
          onChanged: (val) {
            setState(() => _lmkEnabled = val);
            _saveSetting('lmk_enabled', val);
            // if(val) applyLmkRoot();
          },
        ),
        const SizedBox(height: 10),
        _buildTweakSwitch(
          title: 'KSM Optimization',
          value: _ksmEnabled,
          onChanged: (val) {
            setState(() => _ksmEnabled = val);
            _saveSetting('ksm_enabled', val);
          },
        ),
      ],
    );
  }

  Widget _buildTweakSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Switch(
            value: value,
            activeThumbColor: AppColors.royalBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}