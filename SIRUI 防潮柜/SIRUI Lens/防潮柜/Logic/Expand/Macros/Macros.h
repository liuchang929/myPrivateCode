//
////  Macros.h
//  SmartTripod
//
//  Created by sirui on 16/10/10.
//  Copyright © 2016年 SIRUI. All rights reserved.
//


#import "UIColor+Custom.h"



// 文件路径
#define SRContactsFilepath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"contacts.data"]




//判断系统语言
#define CURR_LANG ([[NSLocale preferredLanguages] objectAtIndex:0])
#define LanguageIsEnglish ([CURR_LANG isEqualToString:@"en-US"] || [CURR_LANG isEqualToString:@"en-CA"] || [CURR_LANG isEqualToString:@"en-GB"] || [CURR_LANG isEqualToString:@"en-CN"] || [CURR_LANG isEqualToString:@"en"])


//-----------------功能字段-------------------

//post字段key
#define kDidKey @"did"
#define kDidsKey @"dids"
#define kTypeKey @"type"
#define kPageKey @"page"
#define kCabinetnameKey @"cabinetname"
#define kPwdKey @"pwd"
#define kTpKey @"tp"
#define kTmKey @"tm"
#define kHmKey @"hm"
#define kShmKey @"shm"
#define kLockKey @"lock"
#define kTotalKey @"total"
#define kRowsKey @"rows"
#define kOnlineKey @"online"
#define kStimeKey @"stime"
#define kEtimeKey @"etime"
#define kTimes @"times"



//返回字段key
#define kDataKey @"_data_"
#define kCodeKey @"_code_"


//返回字段value ->string
#define kOnline @"1"
#define kOffline @"0"
#define kClosedoorType @"2"
#define kOpendoorType @"3"


//返回编码code
#define kCode600 @"600"
#define kCode601 @"601"
#define kCode604 @"604"
#define kCode0 @"0"






//#define kTableTag 333


#define kBigCircleWidth kMain_Screen_Width/4
#define kMidCircleWidth kMain_Screen_Width/5




//-----------------------app配置---------------------

#define kApplication        [UIApplication sharedApplication]
#define kKeyWindow          [UIApplication sharedApplication].keyWindow
#define kUserDefaults       [NSUserDefaults standardUserDefaults]
#define kNotificationCenter [NSNotificationCenter defaultCenter]


//App版本号
#define AppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
// 当前设备版本
#define kSystemVersion          ([[UIDevice currentDevice] systemVersion])
#define kFSystemVersion_floatValue          ([[[UIDevice currentDevice] systemVersion] floatValue])


// 是否iPad
#define kIsPad  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//获取当前语言
#define kCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//获得AppDelegate对象
#define kAppDelegateInstance [[UIApplication sharedApplication] delegate]








//弱引用/强引用  可配对引用在外面用kWeakSelf(self)，block用kStrongSelf(self)  也可以单独引用在外面用MPWeakSelf(self) block里面用weakself
#define kWeakSelf(type)  __weak typeof(type) weak##type = type;
#define kStrongSelf(type)  __strong typeof(type) type = weak##type;






//---------------------屏幕尺寸---------------------------
#define kMain_Screen_Bounds [[UIScreen mainScreen] bounds]
#define kMain_Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define kMain_Screen_Width       [[UIScreen mainScreen] bounds].size.width




//----------------------获取图片--------------------------
#define kGetImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]


#define  kGetImageWithContentsOfFile(imageName,type)   [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",imageName] ofType:[NSString stringWithFormat:@"%@",type]]]





//----------------------文件路径--------------------------
//获取temp
#define kPathTemp NSTemporaryDirectory()
//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]








//------------------colors--------------------------------
#define kColorBlue [UIColor getBlueColor]
#define kColorPurpleBlue [UIColor getPurpleBlueColor]

#define kColorPurple [UIColor purpleColor] 
#define kColorLightBlue [UIColor getLightBlueColor]
#define kColorBlack [UIColor getBlackColor]
#define kColorWhite [UIColor getWhiteColor]
#define kColorGray [UIColor getGrayColor]
#define kColorRed [UIColor getRedColor]
#define kColorGreen [UIColor getGreenColor]

//-----------色值-------------------------------------------
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

#define HEXCOLOR(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]

#define COLOR_RGB(rgbValue,a) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) & 0xFF00)>>8))/255.0 blue: ((float)((rgbValue) & 0xFF))/255.0 alpha:(a)]

//-----------中英字体大小(常规/粗体)-------------------------------
#define kSYSTEMFONT(FONTSIZE)    [UIFont systemFontOfSize:FONTSIZE]
#define kBOLDSYSTEMFONT(FONTSIZE)[UIFont boldSystemFontOfSize:FONTSIZE]
#define kFONT(NAME, FONTSIZE)    [UIFont fontWithName:(NAME) size:(FONTSIZE)]

//-----------中文字体－黑体简体-------------------------------
#define kCHINESE_FONT_NAME  @"Heiti SC"
#define kCHINESE_SYSTEM(x) [UIFont fontWithName:CHINESE_FONT_NAME size:x]


//----------------------GetImageView--------------------------
#define kGetImageView(imageName) [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]]


#define  kGetImageViewWithContentsOfFile(imageName,type)  [[UIImageView alloc]initWithImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",imageName] ofType:[NSString stringWithFormat:@"%@",type]]]]




//-------------------------默认设置-------------------------------

//颜色
#define kColorNavBlue [UIColor getNavBlueColor]
#define kColorNormalLabel [UIColor getNormalLabelColor]
#define kColorImportantLabel [UIColor getImportantLabelColor]
#define kColorSeparator [UIColor getSeparatorColor]
#define kColorCellSelected  [UIColor getCellSelectedColor]
#define kColorTableHead [UIColor getTableHeadColor]
#define kColorLoginBG [UIColor getLoginBackgroundColor]
#define kColorBackground [UIColor getBackgroundColor];
#define kColorInchworm [UIColor getInchwormColor];



//字体
#define kFontForTip [UIFont systemFontOfSize:12.f]
#define kFontForInput [UIFont systemFontOfSize:12.f]
#define kFontForBig [UIFont systemFontOfSize:15.f]
#define kFontForSmall [UIFont systemFontOfSize:13.f]
#define kFontForCellTitle [UIFont systemFontOfSize:14.f]

#define kMAX_RECORD_TIME 120.0f   //最大纪录时间
#define kSystemFontOfSize(fontSize) [UIFont systemFontOfSize:fontSize]

#define kImageCollectionCell_Width floorf((Main_Screen_Width - 10*2- 10*3)/3)//集合视图cell中的图片大小

#define kupdateMaximumNumberOfImage 12//最大的上传图片张数



#define kTextFieldHeight  30.f
#define kCommonCellHeight 44
#define kCommonTextFrameHeight 48








//-------------------判断---------------------------------------
//字符串是否为空
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
//数组是否为空
#define kArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)
//字典是否为空
#define kDictIsEmpty(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0)
//是否是空对象
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))

// 是否空对象
#define IS_NULL_CLASS(OBJECT) [OBJECT isKindOfClass:[NSNull class]]





//----------------少用的，放最后----------------------------------
//不同屏幕尺寸字体适配（320，568是因为效果图为IPHONE5 如果不是则根据实际情况修改）
#define kScreenWidthRatio  (Main_Screen_Width / 320.0)
#define kScreenHeightRatio (Main_Screen_Height / 568.0)
#define AdaptedWidth(x)  ceilf((x) * kScreenWidthRatio)
#define AdaptedHeight(x) ceilf((x) * kScreenHeightRatio)
#define AdaptedFontSize(R)     CHINESE_SYSTEM(AdaptedWidth(R))


#define UNICODETOUTF16(x) (((((x - 0x10000) >>10) | 0xD800) << 16)  | (((x-0x10000)&3FF) | 0xDC00))
#define MULITTHREEBYTEUTF16TOUNICODE(x,y) (((((x ^ 0xD800) << 2) | ((y ^ 0xDC00) >> 8)) << 8) | ((y ^ 0xDC00) & 0xFF)) + 0x10000


//获取一段时间间隔
#define kStartTime CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
#define kEndTime   NSLog(@"Time: %f", CFAbsoluteTimeGetCurrent() - start)




//由角度转换弧度
#define kDegreesToRadian(x)      (M_PI * (x) / 180.0)
//由弧度转换角度
#define kRadianToDegrees(radian) (radian * 180.0) / (M_PI)

#define kLockitUrl   @"http://cabinet.sirui.com/lockit"
#define kLockfeedbackUrl   @"http://cabinet.sirui.com/lockfeedback"
#define kUnlockitUrl   @"http://cabinet.sirui.com/unlockit"
#define kUnlockfeedbackUrl   @"http://cabinet.sirui.com/unlockfeedback"
#define kCabinetdataUrl   @"http://cabinet.sirui.com/cabinetdata"
#define kOpendoorUrl   @"http://cabinet.sirui.com/opendoor"
#define kOpendoorfeedbackUrl   @"http://cabinet.sirui.com/opendoorfeedback"
#define kCtrlhumidityUrl   @"http://cabinet.sirui.com/ctrlhumidity"
#define kCtrlhumidityfeedbackUrl   @"http://cabinet.sirui.com/ctrlhumidityfeedback"
#define kDeviceonlineUrl   @"http://cabinet.sirui.com/deviceonline"x
#define kDeviceonlineUrlbyJson       @"http://cabinet.sirui.com/deviceonlinebyjson"

#define kAlarmrecodeUrl   @"http://cabinet.sirui.com/alarmrecode"
#define kDoorrecodeUrl   @"http://cabinet.sirui.com/doorrecode"

//获取设备别名
#define kDeviceNameUrl   @"http://cabinet.sirui.com/findrename"
#define kDeviceNameUrlbyJson                         @"http://cabinet.sirui.com/findrenamebyjson"
//修改设备别名
#define kModifyDeviceNameUrl   @"http://cabinet.sirui.com/setcabinetname"

#ifdef DEBUG
#define SRLog(format, ...) NSLog((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
//#define XLLog(...) NSLog(__VA_ARGS__);
#else
#define SRLog(...);
#endif

////#define kServiceServerUrl @"http://cabinet.sirui.com:5555/"
////#define kSecureServiceServerUrl @"http://app.sirui.com:8443/"
#define kSystemNotificationUrl @"http://cabinet.sirui.com:8080/notice.do"


