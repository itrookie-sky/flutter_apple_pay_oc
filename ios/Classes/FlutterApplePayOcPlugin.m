#import "FlutterApplePayOcPlugin.h"
#import "AppStoreInternalPurchase.h"
#import "MerchantsEntitlements.h"
#import "ViewController.h"

static NSString * const APPSTORE_INTERNAL_PURCHASE = @"AppStoreInternalPurchase";
static NSString * const MERCHANTS_ENTITLEMENTS = @"MerchantsEntitlements";


@implementation FlutterApplePayOcPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_apple_pay_oc"
            binaryMessenger:[registrar messenger]];
  FlutterApplePayOcPlugin* instance = [[FlutterApplePayOcPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if([@"test" isEqualToString:call.method]){
      NSLog(@"通道测试:%@",call.arguments);
      NSDictionary *jsondic = @{
          @"version":@"1.0.0"
      };
      NSData *data = [NSJSONSerialization dataWithJSONObject:jsondic options:kNilOptions error:nil];
      NSString *json = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
      result(json);
  } else if([APPSTORE_INTERNAL_PURCHASE isEqualToString:call.method]) {
      //内购
      [self appStorePay:call result:result];
//      [self appStorePayTest:call result:result];
  } else if([MERCHANTS_ENTITLEMENTS isEqualToString:call.method]) {
      //商户收款
      [self merchantsPay:call result:result];
//       [self merchantsPayTest:call result:result];
  }else{
    result(FlutterMethodNotImplemented);
  }
}

//接口测试
- (void)appStorePayTest:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString *orderInfo = call.arguments;
    NSLog(@"内购测试：%@",orderInfo);
    NSDictionary *jsondic= @{
                               @"orderid":@"aabbcc",
                               @"receipt-data":@"aabbcc"
                               };
      NSData *data = [NSJSONSerialization dataWithJSONObject:jsondic options:kNilOptions error:nil];
      NSString *json = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
      result(json);
}

//内购
- (void)appStorePay:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString *orderInfo = call.arguments;
    ViewController *view_controller = [ViewController getInstance];
    [view_controller showMBHUDColor:@"开始内购支付"];
        
    NSData *data = [orderInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSString *orderid = [jsonDic objectForKey:@"orderid"];
    NSString *price = [jsonDic objectForKey:@"price"];
    NSString *productId = [jsonDic objectForKey:@"productid"];
    int num = price.intValue;
    price = [NSString stringWithFormat:@"%d",num];
        
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        
    AppStoreInternalPurchase *appStoreInternalPurchase = [[AppStoreInternalPurchase alloc] init];
    //    [appStoreInternalPurchase setCurrentProductID:[NSString stringWithFormat:@"com.luxianli.mahjong.internalPay%@",price]];
    [appStoreInternalPurchase setCurrentProductID:productId];
    [viewController addChildViewController:appStoreInternalPurchase];
    appStoreInternalPurchase.view.frame = [[UIScreen mainScreen] bounds];
    [viewController.view addSubview:appStoreInternalPurchase.view];
        
    [appStoreInternalPurchase setHandleApplePayPaymentPurchase:^(NSString *verifyPurchaseBase64) {
            
            NSDictionary *verifyDic = @{
                                        @"orderid":orderid,
                                        @"receipt-data":verifyPurchaseBase64
//                                        @"pixu_type":@"appleStore"
                                        };
            NSData *verifyData = [NSJSONSerialization dataWithJSONObject:verifyDic options:kNilOptions error:nil];
            NSString *verifyString = [[NSString alloc] initWithBytes:verifyData.bytes length:verifyData.length encoding:NSUTF8StringEncoding];
            
            result(verifyString);
    }];
        
    [appStoreInternalPurchase setHandleApplePayPamentPurchaseErrorTips:^(NSString *errorMessage) {
        NSLog(@"错误信息：%@",errorMessage);
        dispatch_async(dispatch_get_main_queue(), ^{
          [view_controller showMBHUDMessage:errorMessage];
          sleep(1);
          [view_controller hideMBHUDProgress];
          NSDictionary *verifyDic = @{
                                      @"orderid":@"",
                                      @"receipt-data":@""
//                                        @"pixu_type":@"appleStore"
                                      };
          NSData *verifyData = [NSJSONSerialization dataWithJSONObject:verifyDic options:kNilOptions error:nil];
          NSString *verifyString = [[NSString alloc] initWithBytes:verifyData.bytes length:verifyData.length encoding:NSUTF8StringEncoding];
        });
//         [view_controller showMBHUDMessage:errorMessage];
//         [view_controller hideMBHUDProgress];
    }];
        
    [appStoreInternalPurchase setHandleApplePayPamentOurchaseMessageTips:^(NSString *message) {
            NSLog(@"购买结果信息：%@",message);
            NSDictionary *verifyDic = @{
                                          @"orderid":@"",
                                          @"receipt-data":@""
    //                                        @"pixu_type":@"appleStore"
                                          };
            NSData *verifyData = [NSJSONSerialization dataWithJSONObject:verifyDic options:kNilOptions error:nil];
            NSString *verifyString = [[NSString alloc] initWithBytes:verifyData.bytes length:verifyData.length encoding:NSUTF8StringEncoding];
            if(message){
//                [SVProgressHUD showWithStatus:message];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [view_controller showMBHUDColor:message];
                });
//                [view_controller showMBHUDColor:message];
//                [view_controller hideMBHUDProgress];
            }else{
//                    [SVProgressHUD dismiss];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [view_controller hideMBHUDProgress];
                });
//                [view_controller hideMBHUDProgress];
            }
    }];
}

//接口测试
- (void)merchantsPayTest:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString *orderInfo = call.arguments;
    NSLog(@"商户收款测试：%@",orderInfo);
      NSDictionary *jsondic= @{
                             @"orderid":@"aabbcc",
                             @"token":@"aabbcc",
                             };
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsondic options:kNilOptions error:nil];
    NSString *json = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    result(json);
}

//商户收款
- (void)merchantsPay:(FlutterMethodCall*)call result:(FlutterResult)result{
       NSString *message = call.arguments;
       
       NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
       NSString *orderid = [json objectForKey:@"orderid"];
       //商号
       NSString *merchatId = [json objectForKey:@"merchatid"];
       
       UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
       MerchantsEntitlements *merchantsViewController = [MerchantsEntitlements getInstance];
       [viewController addChildViewController:merchantsViewController];
       merchantsViewController.view.frame = [[UIScreen mainScreen] bounds];
       [viewController.view addSubview:merchantsViewController.view];

       [[MerchantsEntitlements getInstance] initMerchantsEntitlements];
       
       [[MerchantsEntitlements getInstance] createOrderAndSendToApple:message merchatId:merchatId];
       
       [[MerchantsEntitlements getInstance] setHandleApplePayAuthorizePayment:^BOOL(PKPayment *payment) {
           
           NSDictionary *jsondic;
           if(payment){
               
               PKPaymentToken *token = payment.token;
               NSLog(@"h支付完成开始验证token信息：%@",token);
               
               PKPaymentMethod *method = token.paymentMethod;
               NSLog(@"PKPaymentMethod==%@",method);
               
               NSData *paymentdata = token.paymentData;
               NSString *paymentDataJson = [[NSString alloc] initWithBytes:paymentdata.bytes length:paymentdata.length encoding:NSUTF8StringEncoding];
               
               NSLog(@"h支付完成开始验证paymentdata信息：%@",paymentDataJson);
               
               NSString *paymentDataBase64 = [paymentdata base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
               paymentDataBase64 = [paymentDataBase64 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
               paymentDataBase64 = [paymentDataBase64 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
               paymentDataBase64 = [paymentDataBase64 stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
               
               jsondic = @{
                                     @"orderid":orderid,
                                     @"token":paymentDataBase64
//                                     @"pixu_type":@"applePay"
                                     };
           }else{
               jsondic = @{
                           @"orderid":orderid,
                           @"token":@""
//                           @"pixu_type":@"applePay"
                           };
           }
           NSData *data = [NSJSONSerialization dataWithJSONObject:jsondic options:kNilOptions error:nil];
           NSString *json = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
           
           result(json);
           return YES;
       }];
}
@end
