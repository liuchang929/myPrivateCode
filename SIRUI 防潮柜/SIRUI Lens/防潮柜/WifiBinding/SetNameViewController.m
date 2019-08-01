//
//  SetNameViewController.m
//  SR-Cabinet


#import "SetNameViewController.h"
#import "CustomTextField.h"
//#import "SRContact.h"
#import "JPUSHService.h"
#import "Macros.h"
#import "CommonUtils.h"
#import "UIView+Sizes.h"
#import "SRLocalData.h"

@interface SetNameViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) UIImageView  *backgoundView;
@property (nonatomic, strong) CustomTextField *nameField;
@property (nonatomic, strong) UILabel  *prompt_message;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) NSMutableArray *contacts;

@end

@implementation SetNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    //[self setupNavigationItem];
    [self setupSubView];
    [self addTapGesture];
    [self saveDidAndloadName];


}




/**
 该设备首次airkiss联网默认没有名字，需要用户手动输入，才能完成最后一步添加设备到手机，该接口为防止其他用户第二次走airkiss联网接口添加设备，因此事先根据设备id判断事先有无设备曾经连上，连上则取回之前的设备昵称
 */
-(void)saveDidAndloadName{

    
    
    //根据id尝试获取设备别名(didStr为页面参数传参)
    [self showLoading];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_didStr forKey:kDidsKey];
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:kDeviceNameUrl parameters:dict success:^(id data) {
        [weakSelf stopLoading];
        
        NSDictionary  * dic  =[CommonUtils parserData_key:data];
        
       // SRLog(@"获取别名%@",dic);

        if (dic.count) {
            
            if ([[dic valueForKey:self.didStr] isKindOfClass:[NSString class]]) {
            weakSelf.nameField.textField.text =[dic valueForKey:_didStr];
             }else{
                
                
                             NSString *str = [CommonUtils parserCode_keyMessage:data];
                 
                             if (!str) {
                                 [self showHintMessage:NSLocalizedString(@"Data error", nil)];
                             }else{
                                 [self showHintMessage:str];
                             }
            
                
                
            }
            
            
            
        }
   
        
    } failure:^(NSError *error) {
        [weakSelf stopLoading];
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
    }];
    
}



-(void)viewWillDisappear:(BOOL)animated{
}

//
//- (void)setupNavigationItem {
//    UIButton *left_Button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
//  //  [left_Button setTitle:@"back" forState:UIControlStateNormal];
//    [left_Button addTarget:self action:@selector(left_BarButtonItemAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *left_BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:left_Button];
//    self.navigationItem.leftBarButtonItem = left_BarButtonItem;
//}
//- (void)left_BarButtonItemAction {
//    
//    //不做返回动作，保证只能在点击确认按钮直接返回根页面
//    //[self.navigationController popToRootViewControllerAnimated:YES];
//  
//}


- (void)setupSubView {
    self.title = NSLocalizedString(@"Name your moisture proof ark", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _backgoundView =  kGetImageViewWithContentsOfFile(@"cabinet_background",@"png");
    [self.view addSubview:_backgoundView];
    // 提示文字
    _prompt_message = [[UILabel alloc] init];
    _prompt_message.text = NSLocalizedString(@"The last step", nil);// @"您扫描的条形码结果如下： ";
    _prompt_message.textColor = kColorWhite;
    _prompt_message.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_prompt_message];
    
    
    
    self.nameField = [[CustomTextField alloc] initWithFrame:CGRectZero];
    self.nameField.placeholderText = NSLocalizedString(@"Please enter the name of the cabinet", nil);
    
    self.nameField.textField.keyboardType = UIKeyboardTypeDefault;
    self.nameField.textField.delegate=self;
    self.nameField.textField.textColor = kColorWhite;
    [self.nameField.textField setValue:[UIColor whiteColor]forKeyPath:@"_placeholderLabel.textColor"];
    [self.nameField setBottomLine];
    [self.view addSubview:self.nameField];
    

    
    
    self.doneButton = [[UIButton alloc]init];
    [self.doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.doneButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    
    self.doneButton.layer.borderWidth = 1.f;
    self.doneButton.layer.borderColor = kColorBlue.CGColor;
    self.doneButton.layer.cornerRadius = 15.0f;
    [self.doneButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneButton];
    
    
    
}

/**
 修改名称并且保存
 */
-(void)doneAction{
    
    
    if (self.nameField.textField.text.length==0) {
        
        [self showAlert:NSLocalizedString(@"Please enter the moistureproof ark names", nil) cancelTitle:@"OK"];
        
        return;
    }
    
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_didStr forKey:kDidKey];
    
    //NSLog(@"我的设备号%@",self.didStr);
    [dict setObject:self.nameField.textField.text forKey:kCabinetnameKey];
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:kModifyDeviceNameUrl parameters:dict success:^(id data) {
        
        [weakSelf stopLoading];
        

        if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {
            
          //修改名字成功返回码只有code=0

            
            
            //keychain保存设备id，成功则上传推送tag
            if ([SRLocalData saveDataByDid:self.didStr]) {
                //NSLog(@"保存成功");
                //重新获取所有本地的id,进行tag推送
                NSMutableArray  * keyIMEIArr = [SRLocalData readAllData];
                if (keyIMEIArr.count) {

                    [JPUSHService setTags:[NSSet setWithArray:keyIMEIArr] alias:nil fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
                        
                        //NSLog(@"iTags=======%@",iTags);
                    }];
                }
                
                
                
            }
            
            
            
            
    
        [self.navigationController popToRootViewControllerAnimated:YES];

        }else{
            
            
            NSString *str = [CommonUtils parserCode_keyMessage:data];
            
            if (!str) {
                [self showHintMessage:NSLocalizedString(@"Data error", nil)];
            }else{
                [self showHintMessage:str];
            }

                  [self.navigationController popViewControllerAnimated:YES];
            
            
        }
        
        
    } failure:^(NSError *error) {
        [weakSelf stopLoading];
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
        
      [self.navigationController popViewControllerAnimated:YES];  
    }];
    

    
}



-(void)viewDidLayoutSubviews{
    
    
    _backgoundView.frame = self.view.bounds;
    
    _prompt_message.frame = CGRectMake(0, 80, self.view.frame.size.width, 30);
    _nameField.frame = CGRectMake(5, self.prompt_message.bottom, self.view.width-10, 45);
    
    _doneButton.frame = CGRectMake(10, self.view.bottom-80, self.view.width-20, 45);
    
    
}
@end


