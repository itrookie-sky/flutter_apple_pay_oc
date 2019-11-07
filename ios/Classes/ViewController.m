#import "ViewController.h"
#import "MBProgressHUD/MBProgressHUD.h"

static ViewController *view_controller = nil;

@implementation ViewController{
    
    MBProgressHUD *mbProgressHUD;
}

+(instancetype)getInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view_controller = [[ViewController alloc] init];
    });
    
    return view_controller;
}

- (instancetype)initWithEAGLView:(UIView*)eaglView{
    
    if(self = [super init]){
        self.view = eaglView;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotate {
    return YES;
}

//默认支持d方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    } else {
//        return UIInterfaceOrientationMaskAll;
//    }
    
    return UIInterfaceOrientationMaskLandscape;
}

//优先显示方向
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{

    return UIInterfaceOrientationLandscapeRight|UIInterfaceOrientationLandscapeLeft;
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)showMBHUDColor:(NSString *)loadTitle{
    UIView *view =[UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    dispatch_async(dispatch_get_main_queue(),^{
       if(!mbProgressHUD){
           mbProgressHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
           mbProgressHUD.contentColor = [UIColor colorWithRed:0.f green:0.6f blue:0.7f alpha:1.f];
           
       }
      
       mbProgressHUD.label.text = NSLocalizedString(loadTitle, @"HUD loading title");
    });
}

-(void)showMBHUDMessage:(NSString *)message{
    UIView *view =[UIApplication sharedApplication].keyWindow.rootViewController.view;
    dispatch_async(dispatch_get_main_queue(),^{
        MBProgressHUD *messageHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
        messageHUD.mode = MBProgressHUDModeText;
        messageHUD.label.text = NSLocalizedString(message, @"HUD message title");
        messageHUD.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [messageHUD hideAnimated:YES afterDelay:3.f];
    });
}

-(void)animateMBHUDColor{
    
    [self hideMBHUDProgress];
}

-(void)hideMBHUDProgress{
    if(mbProgressHUD){
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->mbProgressHUD hideAnimated:YES];
                self->mbProgressHUD = nil;
            });
//        });
//        [mbProgressHUD hideAnimated:YES];
//        mbProgressHUD = nil;
    }
}

@end
