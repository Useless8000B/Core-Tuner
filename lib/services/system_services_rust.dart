import 'package:core_tuner/src/rust/api/simple.dart';
import 'package:core_tuner/src/rust/models/battery_model.dart';
import 'package:core_tuner/src/rust/models/ram_model.dart';
import 'package:core_tuner/src/rust/models/zram_model.dart';

class SystemServicesRust {
  static Stream<BatteryModel> getBatteryStream() async* {
    while (true) {
      try {
        final info = getBatteryInfo();
        yield info;
      } catch (e) {
        throw Exception("Error reading rust battery: $e");
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  static Stream<double> getCpuTemperatureStream() async* {
    while (true) {
      try {
        final temp = getCpuTemperature();
        yield temp.toDouble();
      } catch (e) {
        throw Exception("Error reading cpu temperature: $e");
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Stream<RamModel> getRamStream() async* {
    while(true) {
      try {
        final info = getRamInfo();
        yield info;
      } catch (e) {
        throw Exception("Couldn't get ram stream: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Stream<ZramModel> getZramStream() async* {
    while(true) {
      try {
        final info = getSwapInfo();
        yield info;
      } catch (e) {
        throw Exception("Couldn't get zram stream: $e");
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
