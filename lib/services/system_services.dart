import 'dart:io';
import 'dart:async';
import 'package:core_tuner/services/system_services_rust.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemService {
  /*
    ************************************************
    ******* 1. CORE & INFRASTRUCTURE (Root/Magisk) *
    ************************************************
  */

  static Future<bool> checkRootAccess() async {
    try {
      var result = await Process.run('su', ['-c', 'id']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<String> runCommand(String command, {bool root = false}) async {
    try {
      ProcessResult result;
      if (root) {
        result = await Process.run('su', ['-c', command]);
      } else {
        result = await Process.run('sh', ['-c', command]);
      }
      String output = result.stdout.toString().trim();
      return output;
    } catch (e) {
      throw Exception('Error running command: $e');
    }
  }

  static Future<void> saveForMagisk(String key, String value) async {
    try {
      await Process.run('su', [
        '-c',
        'mkdir -p /data/core_tuner && echo "$value" > /data/core_tuner/$key',
      ]);
    } catch (e) {
      throw Exception('Error saving for magisk: $e');
    }
  }

  /*
    ************************************************
    ******* 2. APP STATE & SYNC (SharedPrefs) ******
    ************************************************
  */

  static Future<void> syncAppWithSystem() async {
    final prefs = await SharedPreferences.getInstance();

    int dr = await SystemServicesRust.getDirtyBackgroundRatio();
    if (dr >= 0) {
      await prefs.setInt('vm_dirty_ratio', dr);
    }

    int sw = await SystemServicesRust.getCurrentSwappiness();
    if (sw >= 0) {
      await prefs.setInt('swappiness', sw);
    }

    String gov = await SystemServicesRust.getCurrentGovernor();
    if (gov.isNotEmpty) await prefs.setString('cpu_governor', gov.trim());
  }

  static Future<void> applySavedTweaks() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('cpu_governor')) {
      await SystemServicesRust.setGlobalCpuGovernor(prefs.getString('cpu_governor') ?? "schedutil");
    }

    if (prefs.containsKey('swappiness')) {
      await SystemServicesRust.applySwappiness(prefs.getInt('swappiness') ?? 100);
    }

    if (prefs.containsKey('vm_dirty_ratio')) {
      await SystemServicesRust.applyVmDirtyRatio(prefs.getInt("vm_dirty_ratio") ?? 0);
    }

    if (prefs.containsKey('vm_dirty_background_ratio')) {
      await SystemServicesRust.applyVmDirtyBackgroundRatio(prefs.getInt("vm_dirty_background_ratio") ?? 0);
    }
  }

  static Future<void> applyLmkProfile(int level) async {
    final List<String> profiles = [
      "15360,19200,23040,26880,34415,43737", // Stock
      "18432,23040,27648,32256,55296,80640", // Balanced
      "23040,28160,33280,38400,61440,92160", // Aggressive
      "28160,33280,38400,43520,81920,115200", // Extreme
    ];

    final String selected = profiles[level.clamp(0, 3)];

    final command = '''
      setprop persist.sys.lmk.minfree_levels "$selected"
      setprop sys.lmk.minfree_levels "$selected"
    ''';
  }
}
