//
//  UIViewController+VC_showNotification.m
//  SiRuiIOT
//
//  Created by sirui on 2017/4/20.
//
//

#import "UIViewController+VC_showNotification.h"
#import "AlarmDisplayViewController.h"
#import "DetailsView.h"
CWStatusBarNotification *cabinetAlertNotification;
@implementation UIViewController (VC_showNotification)

-(void)showCabinetAlertNotification{
    cabinetAlertNotification = [CWStatusBarNotification new];
    
    // set default blue color (since iOS 7.1, default window tintColor is black)
   // cabinetAlertNotification.notificationLabelBackgroundColor = [UIColor redColor];

        cabinetAlertNotification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        cabinetAlertNotification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
        cabinetAlertNotification.notificationStyle = CWNotificationStyleNavigationBarNotification;
        
        
        //[cabinetAlertNotification displayNotificationWithMessage:@"" forDuration:10.f];
    
//    UIButton  * sureBtn = [[UIButton alloc]init];
//    sureBtn.backgroundColor = [UIColor redColor];
//    [sureBtn setTitle:@"防潮柜收到警报！" forState:UIControlStateNormal];
    
    
    
    DetailsView * detailsView = [[DetailsView alloc]initWithStyle:LRStyle];
    detailsView.backgroundColor = [UIColor redColor];
    //detailsView.headIv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cabinet_cell_icon"]];
    [detailsView.headIv setImage:[UIImage imageNamed:@"warning_mark_icon"]];
    detailsView.tittleLabel.text= NSLocalizedString(@"You receive an alert from the SR-Cabinet", nil);
    detailsView.tittleLabel.textColor = [UIColor whiteColor];
    [detailsView.tittleLabel setFont:[UIFont systemFontOfSize:14]];
    [detailsView addEditTarget:self action:@selector(tapAction)];
   // [detailsView SetLeftandRightStyle];
//     [sureBtn addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        //    UIView *view = [[NSBundle mainBundle] loadNibNamed:@"CustomView" owner:nil options:nil][0];
     [cabinetAlertNotification displayNotificationWithView:detailsView forDuration:5.f];
  
    
}

-(void)tapAction{
    [cabinetAlertNotification dismissNotification];
    
    AlarmDisplayViewController *alarmDisplayViewController = [[AlarmDisplayViewController alloc] init];
    
    [self presentViewController:alarmDisplayViewController animated:YES completion:nil];
    
    
}
@end
