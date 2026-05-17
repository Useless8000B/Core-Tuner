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

    String dr = await runCommand('cat /proc/sys/vm/dirty_ratio', root: true);
    if (dr.isNotEmpty) {
      await prefs.setInt('vm_dirty_ratio', int.tryParse(dr) ?? 20);
    }

    String sw = await SystemServicesRust.getCurrentSwappiness();
    if (sw.isNotEmpty) {
      await prefs.setInt('swappiness', int.tryParse(sw) ?? 100);
    }

    String gov = await SystemServicesRust.getCurrentGovernor();
    if (gov.isNotEmpty) await prefs.setString('cpu_governor', gov.trim());
  }

  static Future<void> applySavedTweaks() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('cpu_governor')) {
      await SystemServicesRust.setGlobalCpuGovernor(prefs.getString('cpu_governor') ?? "schedutil");
    }

    if (prefs.containsKey('battery_idle_mode')) {}

    if (prefs.containsKey('swappiness')) {
      await SystemServicesRust.applySwappiness(prefs.getInt('swappiness') ?? 100);
    }

    if (prefs.containsKey('vm_dirty_ratio')) {}

    if (prefs.containsKey('vm_dirty_background_ratio')) {}

    if (prefs.containsKey('low_memory_killer')) {}
  }

  /*
    ************************************************
    ******* 4. RAM, ZRAM & VIRTUAL MEMORY **********
    ************************************************
  */

  static Future<void> applyDirtyBackgroundRatio(int value) async {
    try {
      int safeValue = value.clamp(0, 100);
      await runCommand(
        'sysctl -w vm.dirty_background_ratio=$safeValue',
        root: true,
      );
      await saveForMagisk('vm_dirty_background_ratio', safeValue.toString());
    } catch (e) {
      throw Exception("Error applying dirty_background_ratio: $e");
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

    final command =
        '''
      setprop persist.sys.lmk.minfree_levels "$selected"
      setprop sys.lmk.minfree_levels "$selected"
      chown system:system /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null || true
      echo "$selected" > /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null || true
    ''';

    await runCommand(command, root: true);
    await saveForMagisk('lmk_minfree', selected);
  }

  /*
    ************************************************
    ******* 6. STORAGE & SYSTEM UTILS **************
    ************************************************
  */

  static Future<void> clearDalvik() async {
    final command =
        'rm -rf /data/dalvik-cache/*; rm -rf /data/resource-cache/*; rm -rf /data/system/package_cache/*';
    final result = await Process.run('su', ['-c', command]);

    if (result.exitCode != 0) {
      throw Exception("Couldn't wipe cache: ${result.stderr}");
    }
  }

  static Future<String> runStorageTrim() async {
    try {
      String result = await runCommand(
        "fstrim -v /data && fstrim -v /cache",
        root: true,
      );

      if (result.isEmpty) {
        return "Optimization completed.";
      }

      return result.trim();
    } catch (e) {
      return "Error during optimization: $e";
    }
  }

  static Future<void> clearSystemLogs() async {
    try {
      String cmd = """
        logcat -c && 
        rm -rf /data/tombstones/* && 
        rm -rf /data/anr/*
      """;

      await runCommand(cmd, root: true);
    } catch (e) {
      throw Exception("Error clearing logs: $e");
    }
  }

  static Future<void> clearTempFiles() async {
    try {
      String cmd = "rm -rf /data/local/tmp/*";
      await runCommand(cmd, root: true);
    } catch (e) {
      throw Exception("Error clearing tmp files: $e");
    }
  }

  static Future<void> setWifiThrottling(bool enabled) async {
    final value = enabled ? '1' : '0';
    final result = await Process.run('su', [
      '-c',
      'settings put global wifi_scan_throttle_enabled $value',
    ]);

    if (result.exitCode != 0) {
      throw Exception("Couldn't set Wi-Fi throttling: ${result.stderr}");
    }
  }

  static Future<bool> isWifiThrottleEnabled() async {
    final val = await runCommand(
      "settings get global wifi_scan_throttle_enabled",
    );
    return val == "1";
  }
}
