#import "MerchantsEntitlements.h"

static MerchantsEntitlements *merchants_entitlements = nil;

@implementation MerchantsEntitlements

+(instancetype)getInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        merchants_entitlements = [[MerchantsEntitlements alloc] init];
    });
    
    return merchants_entitlements;
}

-(void)viewDidLoad{
    [super viewDidLoad];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotate{
    return self.selectedViewController.shouldAutorotate;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.selectedViewController supportedInterfaceOrientations];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

-(void)initMerchantsEntitlements{
    
    if(![PKPaymentAuthorizationViewController class]){
        
        //PKPaymentAuthorizationViewController需iOS8.0以上支持
        
        NSLog(@"操作系统不支持ApplePay，请升级至9.0以上版本，且iPhone6以上设备才支持");
        
        return;
    }
    //检查当前设备是否可以支付
    else if(![PKPaymentAuthorizationViewController canMakePayments]){
        
        //支付需iOS9.0以上支持
        
        NSLog(@"设备不支持ApplePay，请升级至9.0以上版本，且iPhone6以上设备才支持");
        
        return;
    }
    //检查用户是否可进行某种卡的支付，是否支持Amex、MasterCard、Visa与银联四种卡，，根据自己项目的需要进行检测
    if (@available(iOS 9.2, *)) {
        if(![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkChinaUnionPay,PKPaymentNetworkVisa,PKPaymentNetworkMasterCard]]){
            [self addUserPayBankCard];
        }
    } else {
        if(![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa,PKPaymentNetworkMasterCard]]){
            [self addUserPayBankCard];
        }
    }
    
}

-(void)addUserPayBankCard{
    
    PKPassLibrary *pkl = [[PKPassLibrary alloc] init];
    [pkl openPaymentSetup];
}

#pragma mark - 生成订单-下单
// 创建订单并且发送到苹果 
-(void)createOrderAndSendToApple:(NSString *)orderInfo merchatId:(NSString *)merchatId{
    
    NSData *data = [orderInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSString *order_price = [jsonDic objectForKey:@"price"];
    double num = order_price.doubleValue;
    order_price =[[NSString alloc] initWithFormat:@"%d",num];
//    NSString *order_name = [jsonDic objectForKey:@"name"];
    NSString *order_name = [jsonDic objectForKey:@"order_name"];
    NSString *order_orderNo = [jsonDic objectForKey:@"orderid"];
    
    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    
    request.merchantIdentifier = merchatId;
    request.countryCode = @"CN";
    request.currencyCode = @"CNY";
    
    if(@available(iOS 9.2,*)){
        request.supportedNetworks = @[PKPaymentNetworkChinaUnionPay,PKPaymentNetworkVisa,PKPaymentNetworkMasterCard];
    }else{
        request.supportedNetworks = @[PKPaymentNetworkVisa,PKPaymentNetworkMasterCard];
    }
    
    request.merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityEMV;
    
    if(@available(iOS 11.0,*)){
        
        request.requiredBillingContactFields = [NSSet setWithArray:@[]];
        request.requiredShippingContactFields = [NSSet setWithArray:@[]];
        
    }else{
        
        request.requiredBillingAddressFields = PKAddressFieldNone;
        request.requiredShippingAddressFields = PKAddressFieldNone;
    }
    
    NSMutableArray *paymentSummaryItems = [NSMutableArray arrayWithCapacity:0];
    NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:order_price];
    PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:order_name amount:price];
    [paymentSummaryItems addObject:item];
    request.paymentSummaryItems = paymentSummaryItems;
    
    request.applicationData = [order_orderNo dataUsingEncoding:NSUTF8StringEncoding];
    
    PKPaymentAuthorizationViewController *PKAVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    PKAVC.delegate = self;
    
    [self presentViewController:PKAVC animated:YES completion:nil];
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate
//授权成功回调，在此方法里调用自己服务器验证是否支付成功，然后通过代理Block回传
-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion{
    
    if(self.handleApplePayAuthorizePayment){
        
        BOOL auth = self.handleApplePayAuthorizePayment(payment);
        if(auth){
            completion(PKPaymentAuthorizationStatusSuccess);
        }else{
            completion(PKPaymentAuthorizationStatusFailure);
        }
    }
}
//ios 11.0 以上系统授权成功回调 走此方法
-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                      didAuthorizePayment:(PKPayment *)payment
                                  handler:(void (^)(PKPaymentAuthorizationResult *result))completion API_AVAILABLE(ios(11.0)){
    
    if(self.handleApplePayAuthorizePayment){
        
        BOOL auth = self.handleApplePayAuthorizePayment(payment);
        PKPaymentAuthorizationResult *resl = [[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil];
        if(auth){
            completion(resl);
        }else{
            resl.status = PKPaymentAuthorizationStatusFailure;
            completion(resl);
        }
    }
}

//支付完成回调
- (void)paymentAuthorizationViewControllerDidFinish:(nonnull PKPaymentAuthorizationViewController *)controller {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"支付完成");
}


@end
