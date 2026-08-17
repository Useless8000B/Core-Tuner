import 'dart:async';

import 'package:core_tuner/src/rust/api/simple.dart';
import 'package:core_tuner/src/rust/models/ram_model.dart';
import 'package:core_tuner/src/rust/models/zram_model.dart';
import 'package:flutter/cupertino.dart';

class MemoryServices {
  Stream<RamModel> getRamStream() async* {
    while (true) {
      try {
        yield await getRamInfo();
      } catch (e) {
        debugPrint("Error reading ramStream: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Stream<ZramModel> getZramStream() async* {
    while (true) {
      try {
        yield await getSwapInfo();
      } catch (e) {
        debugPrint("Error reading ZramStream: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }
}