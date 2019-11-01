#import <UIKit/UIKit.h>

@interface ViewController : UITabBarController

+ (instancetype)getInstance;

- (instancetype)initWithEAGLView:(UIView*)eaglView;

-(void)showMBHUDColor:(NSString *)loadTitle;

-(void)showMBHUDMessage:(NSString *)message;

-(void)animateMBHUDColor;

-(void)hideMBHUDProgress;

@end
