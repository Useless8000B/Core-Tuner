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
}
