//
//  YYBuyViewController.m
//  Sight
//
//  Created by fangxue on 2016/10/28.
//  Copyright © 2016年 fangxue. All rights reserved.
//

#import "YYBuyViewController.h"

@interface YYBuyViewController (){
    
    NSString *webString;
    
//    UISegmentedControl *_segment;
}

@end

@implementation YYBuyViewController

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    _segment = [[UISegmentedControl alloc]initWithItems:@[JELocalizedString(@"新闻",nil),JELocalizedString(@"视频",nil)]];
    
//    _segment.selectedSegmentIndex = 0;
    
    /*
    if (_segment.selectedSegmentIndex ==0) {
        
        if([[self currentLanguage] compare:@"zh-Hans-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame || [[self currentLanguage] compare:@"zh-Hant-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            //中文
             webString = @"http://ruipai-tech.com/";
            
        }else{
            
            //非中文
             webString = @"http://www.ruipai-tech.com/index.php?m=news&a=index&classify_id=336";
        }
        
    }if (_segment.selectedSegmentIndex==1) {
        if([[self currentLanguage] compare:@"zh-Hans-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame || [[self currentLanguage] compare:@"zh-Hant-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            //中文
            webString = @"http://ruipai-tech.com/index.php?m=video&a=index&classify_id=301";
        }else{
            
            //非中文
             webString = @"http://www.ruipai-tech.com/index.php?m=video&a=index&classify_id=301";
        }
    }
     */
    
    webString = @"https://www.sirui.com/";
    
//     _segment.frame = CGRectMake(0, 0, 150, 30);
    
//    [_segment addTarget:self action:@selector(segChange:) forControlEvents:UIControlEventValueChanged];
    
//     self.navigationItem.titleView = _segment;
    
    [self loadURL:[NSURL URLWithString:webString]];
}
- (void)segChange:(UISegmentedControl *)sender{
    
    switch (sender.selectedSegmentIndex) {
            
        case 0:{
            
            if([[self currentLanguage] compare:@"zh-Hans-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame || [[self currentLanguage] compare:@"zh-Hant-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame)
            {
                //中文
                webString = @"http://ruipai-tech.com/";
            }else{
                
                //非中文
                webString = @"http://www.ruipai-tech.com/index.php?m=news&a=index&classify_id=336";
            }
            break;
        }
        case 1:{
            
            if([[self currentLanguage] compare:@"zh-Hans-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame || [[self currentLanguage] compare:@"zh-Hant-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame)
            {
                //中文
                webString = @"http://ruipai-tech.com/index.php?m=video&a=index&classify_id=301";
                
            }else{
                
                //非中文
                webString = @"http://www.ruipai-tech.com/index.php?m=video&a=index&classify_id=301";
            }
            break;
        }
        default:
            
            break;
    }
    [self loadURL:[NSURL URLWithString:webString]];
}

-(NSString*)currentLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages objectAtIndex:0];
    return currentLang;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
