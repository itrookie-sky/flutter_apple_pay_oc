#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface AppStoreInternalPurchase : UIViewController <SKPaymentTransactionObserver,SKStoreProductViewControllerDelegate,SKProductsRequestDelegate>

@property (nonatomic,copy) NSString *currentProductID;

@property (nonatomic, copy) void(^handleApplePayPaymentPurchase)(NSString* verifyPurchaseBase64);

@property (nonatomic , copy) void(^handleApplePayPamentPurchaseErrorTips)(NSString* errorMessage);

@property (nonatomic , copy) void(^handleApplePayPamentOurchaseMessageTips)(NSString* message);

@end

