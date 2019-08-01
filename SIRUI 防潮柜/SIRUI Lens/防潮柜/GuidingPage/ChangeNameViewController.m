//
//  ChangeNameViewController.m
//  SR-Cabinet
//
//  Created by sirui on 2017/3/24.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "ChangeNameViewController.h"
#import "CustomTextField.h"
#import "SRCabinetInfo.h"
#import "Macros.h"
#import "CommonUtils.h"
#import "UIView+Sizes.h"
#import "SRDeviceUtils.h"

@interface ChangeNameViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) CustomTextField *nameField;
@property (nonatomic, strong) UIButton       *configureButton;
@property (nonatomic,strong) UIImageView     *backgoundView;

@end

@implementation ChangeNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.title=NSLocalizedString(@"ModifyName", nil);
    [self setupSubviews];
    [self addTapGesture];
    
}



-(void)setupSubviews{
    
    
    NSString *nameStr =  [SRCabinetInfo sharedInstance].deviceName;
    if (!nameStr.length) {
        [self showHintMessage:NSLocalizedString(@"Failed to get the name", nil)];
        }
    self.backgoundView =  kGetImageViewWithContentsOfFile(@"cabinet_background",@"png");
    [self.view addSubview:_backgoundView];

    
    
    
    self.nameField = [[CustomTextField alloc] initWithFrame:CGRectZero];
    self.nameField.placeholderText = NSLocalizedString(@"Please enter a name", nil);//
    self.nameField.textField.keyboardType = UIKeyboardTypeDefault;
    self.nameField.textField.delegate=self;
    self.nameField.textField.textColor = kColorWhite;
    self.nameField.textField.text = nameStr;
    [self.nameField setBottomLine];
    [self.view addSubview:self.nameField];
    
    
    
    
    self.configureButton = [[UIButton alloc]init];
    [self.configureButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.configureButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.configureButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    
    self.configureButton.layer.borderWidth = 1.f;
    self.configureButton.layer.borderColor = kColorBlue.CGColor;
    self.configureButton.layer.cornerRadius = 15.0f;
    
    
    
    [self.configureButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.configureButton];
    

    
    
}






-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
     [self.nameField.textField resignFirstResponder];
    return NO;
}

#pragma mark - Done
-(void)doneAction{
    
    if (!self.nameField.textField.text.length) {
        [self showHintMessage:NSLocalizedString(@"Please enter a name", nil)];
        return;
    }
    
    
    
    
   //没有修改过的保存无需再请求网络
   NSString *nameStr =  [SRCabinetInfo sharedInstance].deviceName;
   if ([nameStr isEqualToString:self.nameField.textField.text]) {
        
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
        
    }
    
    
   
    
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *didStr =  [SRCabinetInfo sharedInstance].deviceIMEI;
       if (!didStr.length) {
        [self showHintMessage:NSLocalizedString(@"Get device ID error", nil)];
        return;
    }
    
    [dict setObject:didStr forKey:kDidKey];
    [dict setObject:self.nameField.textField.text forKey:kCabinetnameKey];
    
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:kModifyDeviceNameUrl parameters:dict success:^(id data) {
        
        [weakSelf stopLoading];

        if ([[CommonUtils parserCode_key:data]isEqualToString:kCode0]) {
             [weakSelf showHintMessage:NSLocalizedString(@"Modified name successfully!", nil)];
            
  
            [SRCabinetInfo sharedInstance].deviceName =  weakSelf.nameField.textField.text;
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
            
        }else{
            NSString *str = [CommonUtils parserCode_keyMessage:data];
            
            if (!str) {
                [weakSelf showHintMessage:NSLocalizedString(@"Data error", nil)];
            }else{
                [weakSelf showHintMessage:str];
            }
            
        }
        

    } failure:^(NSError *error) {
        
        [weakSelf stopLoading];
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
    }];
    
    


}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgoundView.frame = self.view.bounds;

    self.nameField.frame = CGRectMake(20.f, 68.f, self.view.frame.size.width-40.f, [self.nameField viewHeight]);

    if([SRDeviceUtils isNotchScreen])
    {
        self.nameField.frame = CGRectMake(20.f, 68.f + 20.f, self.view.frame.size.width-40.f, [self.nameField viewHeight]);
    }
    
    self.configureButton.frame = (CGRect){30.f, self.nameField.bottom +16.f , self.view.width - 60.0f, 44.0f};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
