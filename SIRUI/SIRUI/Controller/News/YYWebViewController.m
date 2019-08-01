//
//  YYWebViewController.m
//  Sight
//
//  Created by fangxue on 2017/5/17.
//  Copyright © 2017年 fangxue. All rights reserved.
//

#import "YYWebViewController.h"

@interface YYWebViewController ()

@end

@implementation YYWebViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
     [self loadURL:[NSURL URLWithString:self.webString]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
