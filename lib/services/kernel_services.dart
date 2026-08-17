import 'dart:async';

import 'package:core_tuner/src/rust/api/simple.dart';
import 'package:flutter/widgets.dart';

class KernelServices {
  Future<void> applySwappiness(int choice) async {
    try {
      await setSwappiness(choice: choice);
    } catch (e) {
      throw Exception("Coudln't apply swappiness: $e");
    }
  }

  Future<int> getCurrentSwappiness() async {
    try {
      return await getSwappiness();
    } catch (e) {
      debugPrint("Error reading swappiness: $e");
      return 0;
    }
  }

  Future<int> getCurrentDirtyRatio() async {
    try {
      return getVmDirtyRatio();
    } catch (e) {
      debugPrint("Couldn't get current dirty ratio: $e");
      return 0;
    }
  }

  Future<void> applyVmDirtyRatio(int choice) async {
    try {
      return await setVmDirtyRatio(choice: choice);
    } catch (e) {
      throw Exception("Couldn't apply dirty ratio: $e");
    }
  }

  Future<int> getDirtyBackgroundRatio() async {
    try {
      return await getVmDirtyBackgroundRatio();
    } catch (e) {
      debugPrint("Couldn't get dirty background ratio: $e");
      return 0;
    }
  }

  Future<void> applyVmDirtyBackgroundRatio(int choice) async {
    try {
      return await setVmBackgroundDirtyRatio(choice: choice);
    } catch (e) {
      throw Exception("Couldn't apply background dirty ratio: $e");
    }
  }

  Future<void> applyLmkProfile(int choice) async {
    try {
      return await writeLmkProfile(choice: choice);
    } catch (e) {
      throw Exception("Couldn't apply lmk profile: $e");
    }
  }
}
