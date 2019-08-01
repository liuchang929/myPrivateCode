//
//  JEPhotoBrowserViewController.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/5/6.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum browserMode {
    pictureBrowser,
    videoBrowser
}BrowerMode;

@interface JEPhotoBrowserViewController : UIViewController

@property (nonatomic, assign) BrowerMode browerMode;        //相册浏览器模式
@property (nonatomic, strong) NSDictionary *photoBrowserDic;   //相册数据
@property (nonatomic, strong) NSIndexPath *indexPath;       //选中的照片的位置

@end

NS_ASSUME_NONNULL_END
