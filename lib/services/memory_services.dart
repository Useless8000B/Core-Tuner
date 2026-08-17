import 'dart:async';

import 'package:core_tuner/src/rust/api/simple.dart';
import 'package:core_tuner/src/rust/models/ram.dart';
import 'package:core_tuner/src/rust/models/zram.dart';
import 'package:flutter/cupertino.dart';

class MemoryServices {
  Stream<Ram> getRamStream() async* {
    while (true) {
      try {
        yield await getRamInfo();
      } catch (e) {
        debugPrint("Error reading ramStream: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Stream<Zram> getZramStream() async* {
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