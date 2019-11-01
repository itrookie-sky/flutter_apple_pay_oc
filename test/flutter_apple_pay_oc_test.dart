import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_apple_pay_oc/flutter_apple_pay_oc.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_apple_pay_oc');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterApplePayOc.platformVersion, '42');
  });
}
