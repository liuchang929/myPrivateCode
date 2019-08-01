//
//  AppDelegate.m
//  SIRUI Lens
//
//  Created by xml on 2019/6/3.
//  Copyright © 2019年 xml. All rights reserved.
//

#import "AppDelegate.h"
#import "SRDeviceViewController.h"
#import "JPUSHService.h"
#import "SRCabinetInfo.h"
#import "CommonUtils.h"
#import "AlarmDisplayViewController.h"
#import "UIViewController+VC_showNotification.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self initPush:launchOptions];
    
//    UITabBarController *tabBar = [[UITabBarController alloc] init];
//
//
//    SRDeviceViewController *vc1 = [[SRDeviceViewController alloc] init];
//    vc1.title = @"lens";
//    vc1.view.backgroundColor = [UIColor whiteColor];
//    vc1.tabBarItem.title = @"设备";
//    [tabBar addChildViewController:vc1];
    

    
    SRDeviceViewController *vc1 = [[SRDeviceViewController alloc] init];
    vc1.title = @"lens";
    vc1.view.backgroundColor = [UIColor whiteColor];
    vc1.tabBarItem.title = @"设备";

    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc1];
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)initPush:(NSDictionary *)launchOptions
{
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    
    
    [JPUSHService setupWithOption:launchOptions appKey:@"c8147c5752c8bb240e02fe06"//@"eead705fb46a9b06ebf01212"
                          channel:@"App Store"
                 apsForProduction:0
            advertisingIdentifier:@"sirui"];
    
    //[JPUSHService setTags:[NSSet setWithObject:@"5ccf7ff003ac"] callbackSelector:nil object:self];
    
    
    ///SR-Cabinet内部自定义警报推送
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
}


///SR-Cabinet内部自定义警报推送
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    //NSLog(@"dic%@",dic);
    //储存警报id，警报类型，还有警报的时间
    [[SRCabinetInfo sharedInstance] setAlarmId:[dic valueForKey:@"deviceid"]];
    [[SRCabinetInfo sharedInstance] setAlarmType:[dic valueForKey:@"type"]];
    
    
    if (!([dic valueForKey:@"tm"] == nil)) {
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[[dic valueForKey:@"tm"] integerValue]/1000];
        NSString *timeStr  = [CommonUtils stringForNSDate:date];
        
        NSLog(@"date:%@",[dic valueForKey:@"tm"]);
        [[SRCabinetInfo sharedInstance] setAlarmTime:timeStr];
    }
    
    //[AlarmDisplayViewController showAlarmDisplayView];
    
    
    UIViewController *rootVC = [(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController;
    UIViewController *presentedVC = rootVC;
    while (presentedVC.presentedViewController) {
        presentedVC = presentedVC.presentedViewController;
    }
    
    
    if ([presentedVC isKindOfClass:[AlarmDisplayViewController class]]) {
        [AlarmDisplayViewController showAlarmDisplayView];
    }else{
        
        [presentedVC showCabinetAlertNotification];
    }
    
    
}
 




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
