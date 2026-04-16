import 'dart:io';
import 'dart:async';

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
    try {
      await Process.run('su', [
        '-c',
        'echo $governor | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
      ]);
    } catch (e) {
      print("Error trying to set governor: $e");
    }
  }
}
