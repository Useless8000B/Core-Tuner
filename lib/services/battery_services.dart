import 'dart:async';

import 'package:core_tuner/src/rust/api/simple.dart';
import 'package:core_tuner/src/rust/models/battery.dart';
import 'package:flutter/widgets.dart';

class BatteryServices {
  Stream<Battery> getBatteryStream() async* {
    while (true) {
      try {
        yield await getBatteryInfo();
      } catch (e) {
        debugPrint("Error reading battery: $e");
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Stream<double> getBatteryTemperatureStream() async* {
    while (true) {
      try {
        yield await getBatteryTemperature();
      } catch (e) {
        debugPrint("Error reading battery temperature: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
