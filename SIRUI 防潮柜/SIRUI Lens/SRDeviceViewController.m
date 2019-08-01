//
//  SRDeviceViewController.m
//  SIRUI Lens
//
//  Created by xml on 2019/6/10.
//  Copyright © 2019年 xml. All rights reserved.
//

#import "SRDeviceViewController.h"
#import "DeviceListViewController.h"
#import "SRHowToViewController.h"

@interface SRDeviceViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UIButton *howToBtn;

@end

@implementation SRDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"防潮柜",comment: "");
    [self.connectBtn setTitle:NSLocalizedString(@"连接设备",comment: "") forState:UIControlStateNormal];
    [self.howToBtn setTitle:NSLocalizedString(@"如何连接？",comment: "") forState:UIControlStateNormal];
}

- (IBAction)connectDevice:(id)sender {
    DeviceListViewController * vc = [[DeviceListViewController alloc] init];     UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];     [self presentViewController:nav animated:YES completion:nil];
}
- (IBAction)howTo:(id)sender {
    SRHowToViewController *howto = [[SRHowToViewController alloc]initWithNibName:@"SRHowToViewController" bundle:nil];
    
    if ([[self getPreferredLanguage] isEqualToString:@"zh-TW"] ||
        [[self getPreferredLanguage] isEqualToString:@"zh-HK"] ||
        [[self getPreferredLanguage] isEqualToString:@"zh-Hant"] ||
        [[self getPreferredLanguage] isEqualToString:@"zh-Hant-MO"] ||
        [[self getPreferredLanguage] isEqualToString:@"zh-Hant-TW"] ||
        [[self getPreferredLanguage] isEqualToString:@"zh-Hant-HK"] ||
        [[self getPreferredLanguage] isEqualToString:@"zh-Hant-CN"]) {
        //繁
        howto.url = [@"DryBox" stringByAppendingString:@"_tra"];
        
    }else if ([[self getPreferredLanguage] isEqualToString:@"zh-Hans-CN"]) {
        //简
        howto.url = @"DryBox";
        
    }else {
        //其他
        howto.url = [@"DryBox" stringByAppendingString:@"_en"];
    }
    
    howto.title = @"HS70X";
    
    [self.navigationController pushViewController:howto animated:YES];
}

- (NSString*)getPreferredLanguage {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    return preferredLang;
}


@end
