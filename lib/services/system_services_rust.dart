import 'package:core_tuner/src/rust/api/simple.dart';
import 'package:core_tuner/src/rust/models/battery_model.dart';
import 'package:core_tuner/src/rust/models/ram_model.dart';
import 'package:core_tuner/src/rust/models/zram_model.dart';

class SystemServicesRust {
  static Stream<BatteryModel> getBatteryStream() async* {
    while (true) {
      try {
        yield getBatteryInfo();
      } catch (e) {
        throw Exception("Error reading rust battery: $e");
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  static Stream<double> getBatteryTemperatureStream() async* {
    while(true) {
      try {
        yield getBatteryTemperature();
      } catch (e) {
        throw Exception("Error reading battery temperature: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Stream<double> getCpuTemperatureStream() async* {
    while (true) {
      try {
        yield getCpuTemperature().toDouble();
      } catch (e) {
        throw Exception("Error reading cpu temperature: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Stream<RamModel> getRamStream() async* {
    while(true) {
      try {
        yield getRamInfo();
      } catch (e) {
        throw Exception("Couldn't get ram stream: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Stream<ZramModel> getZramStream() async* {
    while(true) {
      try {
        yield getSwapInfo(); 
      } catch (e) {
        throw Exception("Couldn't get zram stream: $e");
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Stream<List<double>> getCpuFrequenciesStream() async* {
    while(true) {
      try {
        yield getCpuFrequencies();
      } catch (e) {
        throw Exception("Couldn't read cpu frequencies: $e");
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
