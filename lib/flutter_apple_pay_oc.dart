import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class FlutterApplePayOc {
  //内购商品
  static const String AppStoreInternalPurchase = "AppStoreInternalPurchase";

  //商户收款
  static const String MerchantsEntitlements = "MerchantsEntitlements";

  static const MethodChannel _channel =
      const MethodChannel('flutter_apple_pay_oc');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  //初始化设置
  static Future<bool> test() async {
    final String success = await _channel.invokeMethod('test');
    print("通道测试");
    print("test ${json.decode(success)}");
  }

  //商户收款
  static Future<MerchatsOrderResult> merchantsPay(
      String orderid, String merchatId) async {
    Map<String, dynamic> info = {
      "orderid": orderid,
      "merchatid": merchatId,
    };
    final String result =
        await _channel.invokeMethod(MerchantsEntitlements, json.encode(info));
    Map<String, dynamic> map = json.decode(result);
    print("$map");
    return MerchatsOrderResult(orderid: map["orderid"], token: map["token"]);
  }

  //内购商品
  static Future<AppStoreInternalPurchaseResult> appStorePay(
      String orderid, int price, String productId) async {
    Map<String, dynamic> info = {
      "orderid": orderid,
      "price": price,
      "productid": productId,
    };
    final String result = await _channel.invokeMethod(
        AppStoreInternalPurchase, json.encode(info));
    Map<String, dynamic> map = json.decode(result);
    print("$map");
    return AppStoreInternalPurchaseResult(
        orderid: map["orderid"], receipt_data: map["receipt-data"]);
  }
}

class MerchatsOrderResult {
  //订单id
  String orderid;

  //票据
  String token;

  MerchatsOrderResult({
    this.orderid,
    this.token,
  }) {
    assert(orderid != null, "orderid Can't be empty");
    assert(token != null, "token Can't be empty");
  }
}

class AppStoreInternalPurchaseResult {
  //订单id
  String orderid;

  //回执信息
  String receipt_data;

  AppStoreInternalPurchaseResult({this.orderid, this.receipt_data}) {
    assert(orderid != null, "orderid Can't be empty");
    assert(receipt_data != null, "receipt_data Can't be empty");
  }
}
