import 'dart:async';

import 'package:core_tuner/src/rust/api/simple.dart';

class WifiServices {
  Future<void> setWifiThrottling(bool enable) async {
    try {
      await setWifiThrottle(enable: enable);
    } catch (e) {
      throw Exception("Coudln't apply wifi throttle: $e");
    }
  }
}
