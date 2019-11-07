import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_apple_pay_oc/flutter_apple_pay_oc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterApplePayOc.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Widget _createRow(String lab, Function func) {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      width: 300,
      height: 70,
      color: Colors.blue,
      child: FlatButton(
        onPressed: func,
        child: Text(
          lab,
          style: TextStyle(
            color: Colors.white,
            fontSize: 44.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('apple_pay'),
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '接口测试',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 44.0,
                ),
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _createRow('test', () {
                      FlutterApplePayOc.test();
                    }),
                    _createRow('testApplePay', () async {
                      var result = await FlutterApplePayOc.appStorePay(
                          "orderid", 1, "128");
                      print(result);
                    }),
                    _createRow('testMerchantsPay', () async {
                      var result = await FlutterApplePayOc.merchantsPay(
                          "orderid", "merchatId", 0.01, "商品");
                      print(result);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
