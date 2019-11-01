//
//  AppStoreInternalPurchase.h
//  Egret_iOS_AppStore
//
//  Created by LuXianli on 2019/7/12.
//  Copyright © 2019 LuXianli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface AppStoreInternalPurchase : UIViewController <SKPaymentTransactionObserver,SKStoreProductViewControllerDelegate,SKProductsRequestDelegate>

@property (nonatomic,copy) NSString *currentProductID;

@property (nonatomic, copy) void(^handleApplePayPaymentPurchase)(NSString* verifyPurchaseBase64);

@property (nonatomic , copy) void(^handleApplePayPamentPurchaseErrorTips)(NSString* errorMessage);

@property (nonatomic , copy) void(^handleApplePayPamentOurchaseMessageTips)(NSString* message);

@end

