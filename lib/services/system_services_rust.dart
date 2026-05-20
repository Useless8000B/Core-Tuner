import 'package:core_tuner/src/rust/api/simple.dart';
import 'package:core_tuner/src/rust/models/battery_model.dart';
import 'package:core_tuner/src/rust/models/ram_model.dart';
import 'package:core_tuner/src/rust/models/storage_model.dart';
import 'package:core_tuner/src/rust/models/zram_model.dart';

class SystemServicesRust {
  static Stream<BatteryModel> getBatteryStream() async* {
    while (true) {
      try {
        yield await getBatteryInfo();
      } catch (e) {
        throw Exception("Error reading battery: $e");
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  static Stream<double> getBatteryTemperatureStream() async* {
    while(true) {
      try {
        yield await getBatteryTemperature();
      } catch (e) {
        throw Exception("Error reading battery temperature: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Stream<double> getCpuTemperatureStream() async* {
    while (true) {
      try {
        yield await getCpuTemperature();
      } catch (e) {
        throw Exception("Error reading cpu temperature: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }
 
  static Future<void> setGlobalCpuGovernor(String governor) async {
    try {
      await setGovernor(governor: governor);
    } catch (e) {
      throw Exception("Error applying governor $e");
    }
  }

  static Stream<List<double>> getCpuFrequenciesStream() async* {
    while(true) {
      try {
        yield await getCpuFrequencies();
      } catch (e) {
        throw Exception("Couldn't read cpu frequencies: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Future<String> getCurrentGovernor() async {
    try {
      return await getCpuGovernor();
    } catch (e) {
      throw Exception("Couldn't get cpu governor: $e");
    }
  }

  static Stream<RamModel> getRamStream() async* {
    while(true) {
      try {
        yield await getRamInfo();
      } catch (e) {
        throw Exception("Couldn't get ram stream: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Stream<ZramModel> getZramStream() async* {
    while(true) {
      try {
        yield await getSwapInfo(); 
      } catch (e) {
        throw Exception("Couldn't get zram stream: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Future<void> applySwappiness(int choice) async {
    try {
      await setSwappiness(choice: choice);
    } catch (e) {
      throw Exception("Coudln't apply swappiness: $e");
    }
  }

  static Future<String> getCurrentSwappiness() async {
    try {
      return await getSwappiness();
    } catch (e) {
      throw Exception("Error reading swappiness: $e");
    }
  }

  static Future<void> applyVmDirtyRatio(int choice) async {
    try {
      return await setVmDirtyRatio(choice: choice);
    } catch (e) {
      throw Exception("Couldn't apply dirty ratio: $e");
    }
  }

  static Future<void> applyVmDirtyBackgroundRatio(int choice) async {
    try {
      return await setVmBackgroundDirtyRatio(choice: choice);
    } catch (e) {
      throw Exception("Couldn't apply background dirty ratio: $e");
    }
  }

  static Stream<StorageModel> getStorageStream() async* {
    while(true) {
      try {
        yield await getStorage();
      } catch (e) {
        throw Exception("Error reading storage: $e");
      }

      await Future.delayed(const Duration(seconds: 20));
    }
  }
}
