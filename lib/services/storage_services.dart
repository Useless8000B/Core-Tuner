import 'dart:async';

import 'package:core_tuner/src/rust/api/simple.dart';
import 'package:core_tuner/src/rust/models/storage.dart';
import 'package:flutter/widgets.dart';

class StorageServices {
  Stream<Storage> getStorageStream() async* {
    while (true) {
      try {
        yield await getStorage();
      } catch (e) {
        debugPrint("Error reading storage: $e");
      }

      await Future.delayed(const Duration(seconds: 20));
    }
  }

  Future<void> runFstrim() async {
    try {
      return await writeFstrim();
    } catch (e) {
      throw Exception("Error running fstrim: $e");
    }
  }

  Future<void> runClearLogs() async {
    try {
      return await writeClearLogs();
    } catch (e) {
      throw Exception("Error clearing logs: $e");
    }
  }

  Future<void> runClearTempFiles() async {
    try {
      return await writeClearTempFiles();
    } catch (e) {
      throw Exception("Error clearing temp files: $e");
    }
  }
}