import 'dart:io';
import 'dart:async';
import 'package:core_tuner/services/cpu_services.dart';
import 'package:core_tuner/services/kernel_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemServices {
  const SystemServices({
    required this.kernelServices,
    required this.cpuServices,
  });

  final KernelServices kernelServices;
  final CpuServices cpuServices;

  /*
    ************************************************
    **** 1. CORE & INFRASTRUCTURE (Root/Magisk) ****
    ************************************************
  */

  Future<bool> checkRootAccess() async {
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

  Future<void> syncAppWithSystem() async {
    final prefs = await SharedPreferences.getInstance();

    int dirtyRatio = await kernelServices.getCurrentDirtyRatio();
    if (dirtyRatio >= 0) {
      await prefs.setInt('vm_dirty_ratio', dirtyRatio);
    }

    int backgroundRatio = await kernelServices.getDirtyBackgroundRatio();
    if (backgroundRatio >= 0) {
      await prefs.setInt('vm_dirty_background_ratio', backgroundRatio);
    }

    int swappiness = await kernelServices.getCurrentSwappiness();
    if (swappiness >= 0) {
      await prefs.setInt('swappiness', swappiness);
    }

    String governor = await cpuServices.getCurrentGovernor();
    if (governor.isNotEmpty) {
      await prefs.setString('cpu_governor', governor.trim());
    }
  }

  Future<void> applySavedTweaks() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('cpu_governor')) {
      await cpuServices.setGlobalCpuGovernor(
        prefs.getString('cpu_governor') ?? "schedutil",
      );
    }

    if (prefs.containsKey('swappiness')) {
      await kernelServices.applySwappiness(prefs.getInt('swappiness') ?? 100);
    }

    if (prefs.containsKey('vm_dirty_ratio')) {
      await kernelServices.applyVmDirtyRatio(
        prefs.getInt("vm_dirty_ratio") ?? 0,
      );
    }

    if (prefs.containsKey('vm_dirty_background_ratio')) {
      await kernelServices.applyVmDirtyBackgroundRatio(
        prefs.getInt("vm_dirty_background_ratio") ?? 0,
      );
    }

    if (prefs.containsKey('low_memory_killer')) {
      await kernelServices.applyLmkProfile(
        prefs.getInt("low_memory_killer") ?? 0,
      );
    }
  }
}
