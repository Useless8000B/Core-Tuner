import 'dart:io';
import 'dart:async';
import 'dart:math';
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

    String sw = await runCommand('cat /proc/sys/vm/swappiness', root: true);
    if (sw.isNotEmpty) {
      await prefs.setInt('swappiness', int.tryParse(sw) ?? 100);
    }

    String gov = await runCommand(
      'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor',
      root: true,
    );
    if (gov.isNotEmpty) await prefs.setString('cpu_governor', gov.trim());

    String cl = await runCommand(
      'cat /data/core_tuner/charge_limit',
      root: true,
    );
    if (cl.isNotEmpty) {
      await prefs.setInt('charge_limit', int.tryParse(cl) ?? 80);
    }
  }

  static Future<void> applySavedTweaks() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('cpu_governor')) {
      await setGlobalGovernor(prefs.getString('cpu_governor') ?? "schedutil");
    }

    if (prefs.containsKey('battery_idle_mode')) {
      await setBatteryIdleMode(prefs.getBool('battery_idle_mode') ?? false);
    }

    if (prefs.containsKey('swappiness')) {
      await applySwappiness(prefs.getInt('swappiness') ?? 100);
    }

    if (prefs.containsKey('vm_dirty_ratio')) {
      await applyDirtyRatio(prefs.getInt('vm_dirty_ratio') ?? 20);
    }

    if (prefs.containsKey('vm_dirty_background_ratio')) {
      await applyDirtyBackgroundRatio(
        prefs.getInt('vm_dirty_background_ratio') ?? 10,
      );
    }

    if (prefs.containsKey('low_memory_killer')) {
      await applyLmkProfile(prefs.getInt('low_memory_killer') ?? 0);
    }

    if (prefs.containsKey('charge_limit')) {
      await applyChargeLimit(prefs.getInt('charge_limit') ?? 80);
    }
  }

  /*
    ************************************************
    ******* 3. CPU & THERMAL MONITORING ************
    ************************************************
  */

  static Future<double> getMaxCpuFreq() async {
    String raw = await runCommand(
      "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq",
    );
    double freq = (double.tryParse(raw) ?? 2000000) / 1000000;
    return freq;
  }

  static Stream<List<double>> getCpuFrequenciesStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      List<double> freqs = [];

      for (int i = 0; i < 8; i++) {
        String raw = await runCommand(
          "cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq",
        );
        double ghz = (double.tryParse(raw) ?? 0.0) / 1000000;
        freqs.add(ghz);
      }
      yield freqs;
    }
  }

  static Future<void> setGlobalGovernor(String governor) async {
    final result = await Process.run('su', [
      '-c',
      'echo $governor | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor',
    ]);

    if (result.exitCode != 0) {
      throw Exception("Couldn't apply governor ${result.stderr}");
    } else {
      await saveForMagisk('governor', governor);
    }
  }

  static Future<String> getCurrentGovernor() async {
    try {
      final result = await runCommand(
        "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor",
      );
      final trimmed = result.trim();
      return trimmed.isNotEmpty ? trimmed : "schedutil";
    } catch (e) {
      return "schedutil";
    }
  }

  static String? _cachedThermalZone;

  static Future<String> _findBestThermalZone() async {
    if (_cachedThermalZone != null) return _cachedThermalZone!;

    List<String> targets = [
      'cpu-thermal',
      'hepta-cpu-max-step',
      'cpuss-0-usr',
      'soc-thermal',
      'cpu-0-0-usr',
    ];

    for (String name in targets) {
      String zoneNum = await runCommand(
        "for i in /sys/class/thermal/thermal_zone*; do if grep -q '$name' \$i/type; then echo \${i##*zone}; break; fi; done",
      );

      if (zoneNum.isNotEmpty && zoneNum != "0") {
        _cachedThermalZone = zoneNum;
        return zoneNum;
      }
    }

    return "0";
  }

  static Stream<double> getTemperatureStream() async* {
    String zone = await _findBestThermalZone();

    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      String raw = await runCommand(
        "cat /sys/class/thermal/thermal_zone$zone/temp",
      );

      double temp = (double.tryParse(raw) ?? 0.0);
      if (temp > 1000) temp /= 1000;

      yield temp;
    }
  }

  /*
    ************************************************
    ******* 4. RAM, ZRAM & VIRTUAL MEMORY **********
    ************************************************
  */

  static Stream<Map<String, double>> getRamStream() {
    return Stream.periodic(const Duration(seconds: 2), (_) async {
      try {
        final content = await runCommand("cat /proc/meminfo", root: false);
        final lines = content.split('\n');

        double total = 0;
        double free = 0;
        double buffers = 0;
        double cached = 0;

        for (var line in lines) {
          final parts = line.split(RegExp(r'\s+'));
          if (line.startsWith('MemTotal:')) total = double.parse(parts[1]);
          if (line.startsWith('MemFree:')) free = double.parse(parts[1]);
          if (line.startsWith('Buffers:')) buffers = double.parse(parts[1]);
          if (line.startsWith('Cached:')) cached = double.parse(parts[1]);
        }

        double usedReal = (total - free - buffers - cached) / 1024 / 1024;
        double totalGB = total / 1024 / 1024;

        return {'used': usedReal, 'total': totalGB};
      } catch (e) {
        return {'used': 0.0, 'total': 0.0};
      }
    }).asyncMap((event) => event);
  }

  static Future<void> applySwappiness(int value) async {
    try {
      await Process.run('su', ['-c', 'echo $value > /proc/sys/vm/swappiness']);
      await saveForMagisk('swappiness', value.toString());
    } catch (e) {
      throw Exception("Error applying swappiness: $e");
    }
  }

  static Future<void> applyDirtyRatio(int value) async {
    try {
      int safeValue = value.clamp(0, 100);
      await runCommand('sysctl -w vm.dirty_ratio=$safeValue', root: true);
      await saveForMagisk('vm_dirty_ratio', safeValue.toString());
    } catch (e) {
      throw Exception("Error applying dirty_ratio: $e");
    }
  }

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

  static Stream<Map<String, dynamic>> getZramDetailedStream() async* {
    while (true) {
      try {
        final result = await Process.run('su', [
          '-c',
          'if [ -d /sys/block/zram0 ]; then cat /sys/block/zram0/mm_stat; cat /sys/block/zram0/disksize; else echo "nodir"; fi',
        ]);

        if (result.exitCode == 0 &&
            result.stdout.toString().trim() != "nodir") {
          final output = result.stdout.toString().trim().split('\n');

          if (output.length >= 2) {
            final stats = output[0].trim().split(RegExp(r'\s+'));
            final double totalBytes = double.tryParse(output[1]) ?? 0.0;
            final double totalGb = totalBytes / (1024 * 1024 * 1024);

            if (stats.length >= 3) {
              double origBytes = double.tryParse(stats[0]) ?? 0.0;
              double secondCol = double.tryParse(stats[1]) ?? 0.0;
              double thirdCol = double.tryParse(stats[2]) ?? 0.0;

              double comprBytes;

              if (secondCol > 1099511627776 || secondCol < 0) {
                comprBytes = thirdCol;
              } else {
                comprBytes = secondCol;
              }

              if (origBytes < 1024 * 1024) {
                origBytes = 0.0;
                comprBytes = 0.0;
              }

              double ratioValue = 0.0;
              if (comprBytes > 0 && origBytes > 0) {
                ratioValue = origBytes / comprBytes;

                if (ratioValue < 0.1 || ratioValue > 20.0) ratioValue = 1.0;
              }

              yield {
                'orig_mb': origBytes / (1024 * 1024),
                'compr_mb': comprBytes / (1024 * 1024),
                'total_gb': totalGb,
                'ratio': ratioValue == 0.0
                    ? "0.0"
                    : ratioValue.toStringAsFixed(1),
              };
            }
          }
        } else {
          yield _emptyZram();
        }
      } catch (e) {
        yield _emptyZram();
      }
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  static Map<String, dynamic> _emptyZram() {
    return {'orig_mb': 0.0, 'compr_mb': 0.0, 'total_gb': 0.0, 'ratio': "0.0"};
  }

  static Future<void> applyZramTweak(bool enable) async {
    await saveForMagisk('zram_enabled', enable ? '1' : '0');
    if (enable) {
      final script = '''
        magiskpolicy --live "allow init self capability sys_admin" 2>/dev/null
        magiskpolicy --live "allow priv_app sysfs_zram dir search" 2>/dev/null
        magiskpolicy --live "allow priv_app sysfs_zram file { getattr open write }" 2>/dev/null
        /system/bin/toybox swapoff /dev/block/zram0 > /dev/null 2>&1
        echo 1 > /sys/block/zram0/reset 2>/dev/null
        echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null
        echo 8 > /sys/block/zram0/max_comp_streams 2>/dev/null
        echo 2147483648 > /sys/block/zram0/disksize || echo 1G > /sys/block/zram0/disksize
        /system/bin/toybox mkswap /dev/block/zram0
        /system/bin/toybox swapon /dev/block/zram0 -p 100
        sysctl -w vm.vfs_cache_pressure=100
      ''';

      await runCommand(script);
    } else {
      final disableScript = '''
        echo 3 > /proc/sys/vm/drop_caches
        timeout 3 /system/bin/toybox swapoff /dev/block/zram0 || true
        echo 1 > /sys/block/zram0/reset || true
      ''';

      await runCommand(disableScript);
    }
  }

  static Future<bool> isZramActive() async {
    try {
      final result = await Process.run('cat', ['/proc/swaps']);
      return result.stdout.toString().contains('zram0');
    } catch (_) {
      return false;
    }
  }

  static Future<void> syncZramState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool shouldBeEnabled = prefs.getBool('zram_swap') ?? false;

    if (!shouldBeEnabled) return;

    final bool isCurrentlyActive = await isZramActive();

    if (!isCurrentlyActive) {
      await applyZramTweak(true);
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
    ******* 5. BATTERY & CHARGING ******************
    ************************************************
  */

  static Stream<Map<String, dynamic>> getBatteryStream() async* {
    while (true) {
      try {
        final result = await Process.run('su', [
          '-c',
          'cat /sys/class/power_supply/battery/capacity /sys/class/power_supply/battery/voltage_now /sys/class/power_supply/battery/current_now /sys/class/power_supply/battery/status',
        ]);

        if (result.exitCode == 0) {
          final lines = result.stdout.toString().trim().split('\n');
          if (lines.length >= 4) {
            double level = double.tryParse(lines[0]) ?? 0;
            double voltage = (double.tryParse(lines[1]) ?? 0) / 1000000;
            double current = (double.tryParse(lines[2]) ?? 0) / 1000;

            String status = lines[3].trim().toLowerCase();
            bool isCharging = status == "charging" || status == "full";

            yield {
              'level': level,
              'voltage': voltage.toStringAsFixed(2),
              'current': current.toInt(),
              'isCharging': isCharging,
              'status': status.toUpperCase(),
            };
          }
        }
      } catch (e) {
        yield {
          'level': 0.0,
          'voltage': '0.0',
          'current': 0,
          'isCharging': false,
          'status': 'UNKNOWN',
        };
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Future<void> setBatterySuspension(bool suspend) async {
    final List<String> chargeControlPaths = [
      '/sys/class/power_supply/battery/input_suspend', // Redmi note 11 - My device
      '/sys/class/power_supply/battery/charging_enabled', // Qualcomm Universal
      '/sys/class/power_supply/battery/battery_charging_enabled', // Sony/Pixel
      '/sys/class/power_supply/battery/charge_control_limit_max', // Modern Kernels
    ];

    final value = suspend ? '1' : '0';
    String cmd = "";
    for (String path in chargeControlPaths) {
      cmd += "if [ -f $path ]; then echo $value > $path; fi; ";
    }

    await runCommand(cmd, root: true);
  }

  static Future<void> applyChargeLimit(int limit) async {
    try {
      await saveForMagisk('charge_limit', limit.toString());

      final String rawLevel = await runCommand(
        'cat /sys/class/power_supply/battery/capacity',
        root: true,
      );
      final int currentLevel = int.tryParse(rawLevel) ?? 0;

      if (currentLevel >= limit) {
        await setBatterySuspension(true);
      } else {
        await setBatterySuspension(false);
      }
    } catch (e) {
      throw Exception("Error applying charge limit: $e");
    }
  }

  static Future<void> setBatteryIdleMode(bool enabled) async {
    await setBatterySuspension(enabled);
    await saveForMagisk('battery_idle_mode', enabled ? '1' : '0');
  }

  static Stream<double> getBatteryTempStream() async* {
    while (true) {
      try {
        String raw = await runCommand("cat /sys/devices/virtual/thermal/thermal_zone40/temp",);
        double temp = double.tryParse(raw.trim()) ?? 0.0;

        if (temp >= 1000) {
          temp /= 1000;
        }
        else if (temp >= 100) {
          temp /= 10;
        }

        yield temp;
      } catch (e) {
        yield 0.0;
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  /*
    ************************************************
    ******* 6. STORAGE & SYSTEM UTILS **************
    ************************************************
  */

  static Stream<Map<String, String>> getStorageStream() async* {
    while (true) {
      try {
        final result = await Process.run('su', ['-c', 'busybox df -m /data']);

        if (result.exitCode == 0) {
          final lines = result.stdout.toString().trim().split('\n');
          final parts = lines[1].split(RegExp(r'\s+'));

          if (parts.length >= 4) {
            double totalPartM = double.parse(parts[1]);
            double freeM = double.parse(parts[3]);
            double nominalTotalGb = _getNominalSize(totalPartM / 1024);

            double usedGb = nominalTotalGb - (freeM / 1024);
            double hardwareMargin = nominalTotalGb * 0.045;
            double displayUsedGb = usedGb - hardwareMargin;

            int percent = ((displayUsedGb / nominalTotalGb) * 100).round();

            yield {
              'total': "${nominalTotalGb.toStringAsFixed(0)} GB",
              'used': displayUsedGb.toStringAsFixed(1),
              'percent': "$percent%",
            };
          }
        }
      } catch (e) {
        throw Exception("Storage Error: $e");
      }
      await Future.delayed(const Duration(seconds: 15));
    }
  }

  static double _getNominalSize(double partitionSizeGb) {
    double power = log(partitionSizeGb) / log(2);
    double nextPower = pow(2, power.ceil()).toDouble();

    if ((nextPower - partitionSizeGb) > (nextPower * 0.4)) {
      return nextPower / 2;
    }

    return nextPower;
  }

  static Future<void> clearDalvik() async {
    final command =
        'rm -rf /data/dalvik-cache/*; rm -rf /data/resource-cache/*; rm -rf /data/system/package_cache/*';
    final result = await Process.run('su', ['-c', command]);

    if (result.exitCode != 0) {
      throw Exception("Couldn't wipe cache: ${result.stderr}");
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
