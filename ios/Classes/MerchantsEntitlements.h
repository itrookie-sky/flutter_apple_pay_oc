#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import <PassKit/PKPaymentAuthorizationViewController.h>

@interface MerchantsEntitlements : UITabBarController <PKPaymentAuthorizationViewControllerDelegate>

/**
 支付单例
 */
+ (instancetype)getInstance;

/**
 处理ios9.0后通过左上角或者其他非正常途径返回APP导致支付回调不成功的问题
 @note 在支付页面进行调用处理
 @param handler 外部处理(调用自己服务验证支付是否成功)
 */
@property (nonatomic, copy) void(^handleBackToAppByUnusualWay)(void);

/**
 ApplePay授权成功后，根据PKPayment里的信息调用自己服务验证支付是否成功，成功返回YES，失败返回NO
 @note 在支付页面进行调用处理
 @param payment 订单信息(调用自己服务验证支付是否成功)
 */
@property (nonatomic, copy) BOOL(^handleApplePayAuthorizePayment)(PKPayment* payment);

-(void)initMerchantsEntitlements;

/**
 创建订单并且发送到苹果
 @param orderInfo 订单信息 json格式
 */
-(void)createOrderAndSendToApple:(NSString *)orderInfo merchatId:(NSString *)merchatId;
@end
