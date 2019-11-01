import 'dart:async';

import 'package:flutter/services.dart';

class FlutterApplePayOc {
  static const MethodChannel _channel =
      const MethodChannel('flutter_apple_pay_oc');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
