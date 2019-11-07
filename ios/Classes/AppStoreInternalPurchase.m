#import "AppStoreInternalPurchase.h"

@implementation AppStoreInternalPurchase


-(void)viewDidLoad{

    [super viewDidLoad];
    
    [self createAppStoreInternalPurchase];
}

-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotate{
    
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
}

#pragma mark -购买逻辑

-(void)createAppStoreInternalPurchase{
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    if([SKPaymentQueue canMakePayments]){
        
        [self requestProductData:self.currentProductID];
    }else{
        
        NSLog(@"不支持内购，开始执行销毁逻辑");
        
    }
}

-(void)requestProductData:(NSString *)productID{
    
    NSLog(@"开始请求内购商品信息");
    
    if(self.handleApplePayPamentOurchaseMessageTips){
        self.handleApplePayPamentOurchaseMessageTips(@"开始请求商品信息");
    }
    
    NSArray *productArray = [[NSArray alloc] initWithObjects:productID, nil];
    
    NSSet *productSet = [NSSet setWithArray:productArray];
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
    request.delegate = self;
    [request start];
    
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"收到返回信息");
    
    NSArray *productArray = response.products;
    
    if([productArray count] == 0){
        
        if(self.handleApplePayPamentOurchaseMessageTips){
            self.handleApplePayPamentOurchaseMessageTips(nil);
        }
        NSLog(@"n没有可以购买商品");
        return;
    }
    
    NSLog(@"内购产品ID：%@",response.invalidProductIdentifiers);
    NSLog(@"内购可付费产品数量：%lu",(unsigned long)[productArray count]);
    
    SKProduct *buyProduct = nil;
    
    for(SKProduct *product in productArray){
        
        NSLog(@"%@",product.description);
        NSLog(@"%@",product.localizedTitle);
        NSLog(@"%@",product.localizedDescription);
        NSLog(@"%@",product.price);
        NSLog(@"%@",product.productIdentifier);
        
        if([product.productIdentifier isEqualToString:self.currentProductID]){
            
            buyProduct = product;
        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:buyProduct];
    
    NSLog(@"发起内购购买请求");
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    
    if(self.handleApplePayPamentPurchaseErrorTips){
        self.handleApplePayPamentPurchaseErrorTips(@"支付失败");
    }
    NSLog(@"内购支付错误---------%@",error);
}

-(void)requestDidFinish:(SKRequest *)request{
    
    if(self.handleApplePayPamentOurchaseMessageTips){
        self.handleApplePayPamentOurchaseMessageTips(@"内购支付结束");
    }
    NSLog(@"z内购支付结束");
    
}

-(void)verifyPurchaseWithPaymentTransaction{
    
    //获取数据
    NSURL *url = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    //游戏服务器验证
    if(self.handleApplePayPaymentPurchase){
        
        self.handleApplePayPaymentPurchase(base64);
    }
    
    //应用本身验证
//    [self appVerifyPurchase:base64];
}

#define SANDBOX_URL @"https://sandbox.itunes.apple.com/verifyReceipt"
#define RELEASE_URL @"https://buy.itunes.apple.com/verifyReceipt"

-(void)appVerifyPurchase:(NSString *)receiptBase64String{
    
    NSDictionary *requestDic = @{
                                 @"receipt-data":receiptBase64String
                                 };
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestDic options:kNilOptions error:nil];
    
    NSString *requestBody = [[NSString alloc] initWithBytes:requestData.bytes length:requestData.length encoding:NSUTF8StringEncoding];
    
    NSURL *requestURL = [NSURL URLWithString:SANDBOX_URL];
    NSMutableURLRequest *mutableUrlRequest = [NSMutableURLRequest requestWithURL:requestURL];
    mutableUrlRequest.HTTPBody = requestData;
    mutableUrlRequest.HTTPMethod = @"POST";
    
    NSString *error = nil;
    
}

#pragma mark -SKProductsRequestDelegate

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    NSLog(@"productViewController显示完成");
}

#pragma mark - SKPaymentTransactionObserver
//监听内购支付结果
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
    for(SKPaymentTransaction *skPaymentTransaction in transactions){
        
        /**
         SKPaymentTransactionStatePurchasing,    正在购买
         SKPaymentTransactionStatePurchased,     已经购买
         SKPaymentTransactionStateFailed,        购买失败
         SKPaymentTransactionStateRestored,      回复购买中
         SKPaymentTransactionStateDeferred       交易还在队列里面，但最终状态还没有决定
         */
        
        switch (skPaymentTransaction.transactionState) {
            
            //支付成功
            case SKPaymentTransactionStatePurchased:
                NSLog(@"商品购买成功");
                [self verifyPurchaseWithPaymentTransaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:skPaymentTransaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"商品购买失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:skPaymentTransaction];
                if(self.handleApplePayPamentPurchaseErrorTips){
                    self.handleApplePayPamentPurchaseErrorTips(@"商品购买失败");
                }
                break;
                
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品已经添加购买列表");
                break;
                
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过此商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:skPaymentTransaction];
                break;
                
            default:
                NSLog(@"内购未知结果：%ld",(long)skPaymentTransaction.transactionState);
                break;
        }
        
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    NSLog(@"Transactions执行完成");
//    self.view.frame = CGRectMake(0, 0, 0, 0);
}

-(void)dealloc{
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
