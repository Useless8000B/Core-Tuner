import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SystemService {
  static Future<String> runCommand(String command, {bool root = false}) async {
    try {
      ProcessResult result;
      if (root) {
        result = await Process.run('su', ['-c', command]);
      } else {
        result = await Process.run('sh', ['-c', command]);
      }
      return result.stdout.toString().trim();
    } catch (e) {
      return "0";
    }
  }

  static Stream<double> getTemperatureStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      String raw = await runCommand(
        "cat /sys/class/thermal/thermal_zone0/temp",
      );
      double temp = (double.tryParse(raw) ?? 0.0) / 1000;
      yield temp;
    }
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

  static Future<bool> checkRootAccess() async {
    try {
      var result = await Process.run('su', ['-c', 'id']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setGlobalGovernor(String governor) async {
    final result = await Process.run('su', [
      '-c',
      'echo $governor | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor',
    ]);

    if (result.exitCode != 0) {
      throw Exception("Couldn't apply governor ${result.stderr}");
    }
  }

  static Stream<Map<String, double>> getRamStream() {
    return Stream.periodic(const Duration(seconds: 2), (_) async {
      try {
        final result = await Process.run('cat', ['/proc/meminfo']);
        final lines = result.stdout.toString().split('\n');

        double total = 0;
        double available = 0;

        for (var line in lines) {
          if (line.startsWith('MemTotal:')) {
            total = double.parse(line.split(RegExp(r'\s+'))[1]);
          }
          if (line.startsWith('MemAvailable:')) {
            available = double.parse(line.split(RegExp(r'\s+'))[1]);
          }
        }

        double used = (total - available) / 1024 / 1024;
        double totalGB = total / 1024 / 1024;

        return {'used': used, 'total': totalGB};
      } catch (e) {
        return {'used': 0.0, 'total': 0.0};
      }
    }).asyncMap((event) => event);
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

            if (stats.length >= 2) {
              double origBytes = double.tryParse(stats[0]) ?? 0.0;
              double comprBytes = double.tryParse(stats[1]) ?? 0.0;

              if (comprBytes > totalBytes || comprBytes < 0) {
                comprBytes = origBytes;
              }

              double ratioValue = 1.0;
              if (comprBytes > 0 && origBytes > 0) {
                ratioValue = origBytes / comprBytes;
                if (ratioValue > 5.0 || ratioValue < 0.8) ratioValue = 1.0;
              }

              yield {
                'orig_mb': origBytes / (1024 * 1024),
                'compr_mb': comprBytes / (1024 * 1024),
                'total_gb': totalGb,
                'ratio': ratioValue.toStringAsFixed(1),
              };
            }
          }
        } else {
          yield {
            'orig_mb': 0.0,
            'compr_mb': 0.0,
            'total_gb': 0.0,
            'ratio': "1.0",
          };
        }
      } catch (e) {
        yield {
          'orig_mb': 0.0,
          'compr_mb': 0.0,
          'total_gb': 0.0,
          'ratio': "1.0",
        };
      }
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  static Future<void> applyZramTweak(bool enable) async {
    if (enable) {
      final script = '''
      current_size=\$(cat /sys/block/zram0/disksize 2>/dev/null || echo 0)
      total_mem=\$(cat /proc/meminfo | grep MemTotal | awk '{print \$2}')
      target_size=\$((total_mem * 1024 / 2))

      if swapon -s | grep -q "/dev/block/zram0" && [ "\$current_size" -eq "\$target_size" ]; then
        exit 0
      fi

      swapoff /dev/block/zram0 > /dev/null 2>&1

      echo 1 > /sys/block/zram0/reset

      echo zstd > /sys/block/zram0/comp_algorithm || echo lz4 > /sys/block/zram0/comp_algorithm

      echo \$target_size > /sys/block/zram0/disksize

      mkswap /dev/block/zram0 > /dev/null 2>&1
      swapon /dev/block/zram0 -p 100 > /dev/null 2>&1
    ''';

      final result = await Process.run('su', ['-c', script]);
      if (result.exitCode != 0) {
        throw Exception("Erro ao configurar kernel: \${result.stderr}");
      }
    } else {
      final script = '''
      swapoff /dev/block/zram0 > /dev/null 2>&1
      echo 1 > /sys/block/zram0/reset
    ''';

      await Process.run('su', ['-c', script]);
    }
  }

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
        debugPrint("Storage Error: $e");
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

  static Future<bool> isZramActive() async {
    final disksize = await runCommand("cat /sys/block/zram0/disksize");
    final totalMemRaw = await runCommand(
      "cat /proc/meminfo | grep MemTotal | awk '{print \$2}'",
    );

    double current = double.tryParse(disksize) ?? 0;
    double total = (double.tryParse(totalMemRaw) ?? 0) * 1024;

    return (current - (total / 2)).abs() < 10 * 1024 * 1024 && current > 0;
  }

  static Future<bool> isWifiThrottleEnabled() async {
    final val = await runCommand(
      "settings get global wifi_scan_throttle_enabled",
    );
    return val == "1";
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
}
