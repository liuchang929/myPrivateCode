//
//  AppDelegate.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/2/21.
//  Copyright © 2019年 JennyT. All rights reserved.
//

#import "AppDelegate.h"
#import "JEMainViewController.h"
#import "JEBluetoothManager.h"
#import "BaseViewController.h"
#import "BaseNavigationController.h"
#import "BaseTabBarController.h"
#import "JEAlbumViewController.h"
#import "JESmartCameraViewController.h"
#import "XHVersion.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;    //状态栏字体颜色
    
    //强制纠正语言
    NSArray *languages = [NSLocale preferredLanguages];
    
    NSString *language = [languages objectAtIndex:0];
    
    if ([language hasPrefix:@"zh"]) {//检测开头匹配，是否为中文
        [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:@"appLanguage"];//App语言设置为中文
    }
    else{//其他语言
        [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"appLanguage"];//App语言设置为英文
    }
    
    [self initControllers]; //初始化控制器
    
    //启动图展示停留
    [NSThread sleepForTimeInterval:1.5];
    
    return YES;
}

- (void)initControllers {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NSArray *vcTitles = @[NSLocalizedString(@"Devices", nil), NSLocalizedString(@"Media Library", nil), NSLocalizedString(@"News", nil)];
    
    NSArray *controllersNames = @[@"JEMainViewController", @"JEAlbumViewController", @"YYBuyViewController"];
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < controllersNames.count; i++) {
        BaseViewController *vc = [[NSClassFromString(controllersNames[i]) alloc] init];
        
        vc.title = vcTitles[i];
        
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        
        [controllers addObject:nav];
    }
    
    BaseTabBarController *tbController = [[BaseTabBarController alloc] init];
    
    tbController.viewControllers = controllers;
    
    NSArray *imagesN = @[@"icon_main_devices",@"icon_main_gallery",@"icon_main_news",@"icon_main_my"];
    
    for (int index = 0; index < tbController.viewControllers.count; index++) {
        
        UITabBarItem *item = (UITabBarItem *)tbController.tabBar.items[index];
        
        item.title = vcTitles[index];
        
        item.image = [UIImage imageNamed:[imagesN objectAtIndex:index]];
    }
    
    self.window.rootViewController = tbController;
    
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;  //不熄屏
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

//应用被用户双击 home 键杀死
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[JEBluetoothManager shareBLESingleton] disconnectDevice];
    [UIApplication sharedApplication].idleTimerDisabled = NO;   //取消不熄屏
    
}


@end
