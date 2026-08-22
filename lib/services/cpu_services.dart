import 'dart:async';

import 'package:core_tuner/src/rust/api/simple.dart';
import 'package:flutter/widgets.dart';

class CpuServices {
  Stream<double> getCpuTemperatureStream() async* {
    while (true) {
      try {
        yield await getCpuTemperature();
      } catch (e) {
        debugPrint("Error reading cpu temperature: $e");
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> setGlobalCpuGovernor(String governor) async {
    try {
      await setGovernor(governor: governor);
    } catch (e) {
      throw Exception("Error applying governor $e");
    }
  }

  Stream<List<double>> getCpuFrequenciesStream() async* {
    while (true) {
      try {
        yield await getCpuFrequencies();
      } catch (e) {
        debugPrint("Couldn't read cpu frequencies: $e");
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<String> getCurrentGovernor() async {
    try {
      return await getCpuGovernor();
    } catch (e) {
      debugPrint("Couldn't get cpu governor: $e");
      return "N/A";
    }
  }
}
