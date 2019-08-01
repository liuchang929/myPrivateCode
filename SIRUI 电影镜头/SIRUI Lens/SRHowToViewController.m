//
//  SRHowToViewController.m
//  SiRuiIOT
//
//  Created by sirui on 2017/3/1.
//
//

#import "SRHowToViewController.h"

@interface SRHowToViewController ()

@end

@implementation SRHowToViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40,40)];
    [button setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    
    NSURL *URL = [NSURL URLWithString:@"https://cn.sirui.com/api/app/instructions/product/vd-01"];
    if([_url containsString:@"en"])
    {
        URL = [NSURL URLWithString:@"https://en.sirui.com/api/app/instructions/product/vd-01"];
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:URL];
    [_displayView loadRequest:req];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
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
