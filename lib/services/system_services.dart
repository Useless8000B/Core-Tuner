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

  /*
    ************************************************
    ******* 2. APP STATE & SYNC (SharedPrefs) ******
    ************************************************
  */

  static Future<void> syncAppWithSystem() async {
    final prefs = await SharedPreferences.getInstance();

    int dirtyRatio = await SystemServicesRust.getCurrentDirtyRatio();
    if (dirtyRatio >= 0) {
      await prefs.setInt('vm_dirty_ratio', dirtyRatio);
    }

    int backgroundRatio = await SystemServicesRust.getDirtyBackgroundRatio();
    if (backgroundRatio >= 0) {
      await prefs.setInt('vm_dirty_background_ratio', backgroundRatio);
    }

    int swappiness = await SystemServicesRust.getCurrentSwappiness();
    if (swappiness >= 0) {
      await prefs.setInt('swappiness', swappiness);
    }

    String governor = await SystemServicesRust.getCurrentGovernor();
    if (governor.isNotEmpty) {
      await prefs.setString('cpu_governor', governor.trim());
    }
  }

  static Future<void> applySavedTweaks() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('cpu_governor')) {
      await SystemServicesRust.setGlobalCpuGovernor(
        prefs.getString('cpu_governor') ?? "schedutil",
      );
    }

    if (prefs.containsKey('swappiness')) {
      await SystemServicesRust.applySwappiness(
        prefs.getInt('swappiness') ?? 100,
      );
    }

    if (prefs.containsKey('vm_dirty_ratio')) {
      await SystemServicesRust.applyVmDirtyRatio(
        prefs.getInt("vm_dirty_ratio") ?? 0,
      );
    }

    if (prefs.containsKey('vm_dirty_background_ratio')) {
      await SystemServicesRust.applyVmDirtyBackgroundRatio(
        prefs.getInt("vm_dirty_background_ratio") ?? 0,
      );
    }

    if (prefs.containsKey('low_memory_killer')) {
      await SystemServicesRust.applyLmkProfile(
        prefs.getInt("low_memory_killer") ?? 0,
      );
    }
  }
}
