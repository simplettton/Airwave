//
//  RecordReportViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/14.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "RecordReportViewController.h"
#import "HttpClient.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "HttpError.h"
#import "HttpHelper.h"
#import "ZWGraphicView.h"
#import "BEPresentView.h"
#import "SVProgressHUD.h"
#import "XWScanImage.h"
#import "UIImage+Rotate.h"
#define ScreenW self.view.bounds.size.width
#define ScreenH self.view.bounds.size.height
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
static NSString *AIRWAVETYPE = @"7681";
static NSString *BLOODDEVTYPE = @"8888";
@interface RecordReportViewController ()<UITextViewDelegate>
@property (strong, nonatomic)NSString *idString;

@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UITextView *suggestTextView;
@property (weak, nonatomic) IBOutlet UILabel *reportDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *treatDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatWayLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeOrLevelLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *signImageView;
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (strong ,nonatomic) UIImage *signImage;
@property (weak, nonatomic) IBOutlet UIButton *suggestButton;

@property (weak, nonatomic) IBOutlet UIView *photoView;

@property (nonatomic,strong) ZWGraphicView * drawView;
@property (nonatomic,strong) BEPresentView *presentView;
- (IBAction)sign:(id)sender;
- (IBAction)enterSuggest:(id)sender;

@end

@implementation RecordReportViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem.tintColor = UIColorFromHex(0x65BBA9);
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    //补全所有边框线
    self.addressTextView.layer.borderWidth = 0.8;
    self.headerImageView.layer.borderWidth = 0.8;
    self.suggestTextView.layer.borderWidth = 0.8;
    self.photoView.layer.borderWidth = 0.8;
    
    self.addressTextView.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    self.headerImageView.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    self.suggestTextView.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    self.photoView.layer.borderColor = UIColorFromHex(0x333333).CGColor;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //关闭按钮
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeSelf:)];
    self.navigationItem.leftBarButtonItem = barButton;
    
    //上传按钮
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"shangchuan"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightBarButton;

    
    //设置图片自动缩放
    self.signImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //设置图片居中显示
    [self.resultImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.resultImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.resultImageView.clipsToBounds  = YES;
    //图片添加点击放大手势
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanBigImageClick1:)];
    [self.resultImageView addGestureRecognizer:tapGestureRecognizer1];
    //让UIImageView和它的父类开启用户交互属性
    [self.resultImageView setUserInteractionEnabled:YES];
    
    
    //配置界面内容

    self.nameLabel.text = [NSString stringWithFormat:@"%@",self.record.name];
    self.sexLabel.text = [NSString stringWithFormat:@"%@",self.record.sex];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",self.record.age];
    self.phoneLabel.text = [NSString stringWithFormat:@"%@",self.record.phoneNumber];
    self.addressTextView.text = [NSString stringWithFormat:@"%@",self.record.address];
    
    self.treatTimeLabel.text = [NSString stringWithFormat:@"%@",self.record.durationString];
    if ([self.record.type isEqualToString:BLOODDEVTYPE])
    {
        self.modeOrLevelLabel.text = @"治疗强度";
        self.treatWayLabel.text = [NSString stringWithFormat:@"  %d",self.record.treatWay];
    }else if([self.record.type isEqualToString:AIRWAVETYPE]){
        self.modeOrLevelLabel.text = @"治疗模式";
        self.treatWayLabel.text = [NSString stringWithFormat:@"  %@",self.record.treatWayString];
    }
    self.treatDateLabel.text = [NSString stringWithFormat:@"  %@",self.record.dateString];

    
    
    
    if (self.record.imagePath>0)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *imagePath = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",self.record.idString]];
            self.record.imagePath = imagePath;
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            dispatch_async(dispatch_get_main_queue(), ^{
//                self.resultImageView.contentMode = UIViewContentModeScaleAspectFit;
                self.resultImageView.image = [image rotate:UIImageOrientationRight];
            });
        });
    }
    else
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 35, 18, 21)];
        label.text = @"无";
        label.textColor = UIColorFromHex(0x333333);
        label.font = [UIFont systemFontOfSize:14];
        [self.photoView addSubview:label];
    }
    
    //报告时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy/MM/dd";
    self.reportDateLabel.text = [formatter stringFromDate:[NSDate date]];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}
- (void)closeSelf:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
//    NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];

}
-(void)upload:(id)sender
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //上传数据
    [params setObject:self.record.name forKey:@"Name"];
    [params setObject:self.record.sex forKey:@"Sex"];
    [params setObject:self.record.age forKey:@"Age"];
    [params setObject:self.record.phoneNumber forKey:@"Phone"];
    [params setObject:self.record.address forKey:@"Address"];
    [params setObject:self.record.type forKey:@"Type"];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[self.record.dateTime timeIntervalSince1970]];
    
    [params setObject:timeSp forKey:@"Date"];
    [params setObject:[NSString stringWithFormat:@"%d",(unsigned int)self.record.duration] forKey:@"Treattime"];
    [params setObject:[NSString stringWithFormat:@"%d",self.record.treatWay] forKey:@"Mode"];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[HttpHelper instance] post:@"add"
                             params:params
                           hasToken:NO
                         onResponse:^(HttpResponse *responseObject) {
                             
                             NSDictionary* jsonDict = [responseObject jsonDist];
                             NSLog(@"AddReturnJson = %@",jsonDict);
                             
                             if(jsonDict != nil)
                             {
                                 int state = [[jsonDict objectForKey:@"State"] intValue];
                                 self.idString = [jsonDict objectForKey:@"Id"];

                                     
                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                         //上传照片
                                         if (self.record.imagePath!=nil)
                                         {
                                             NSMutableDictionary *params1 = [NSMutableDictionary dictionary];
                                             UIImage *imageBefore = [[UIImage imageWithContentsOfFile:self.record.imagePath]rotate:UIImageOrientationRight];
                                             UIImage *image = [self scaleImage:imageBefore maxSize:1000];
                                             NSData *imageData;
                                             if (UIImagePNGRepresentation(image) == nil)
                                             {
                                                 imageData = UIImageJPEGRepresentation(image, 1);
                                             }
                                             else
                                             {
                                                 imageData = UIImageJPEGRepresentation(image, 0.8);
                                             }
                                             NSString *imageString = [imageData base64EncodedStringWithOptions:0];
                                             [params1 setObject:imageString forKey:@"Img"];
                                             
                                         [[HttpHelper instance] post:[NSString stringWithFormat:@"addimg&Id=%@",self.idString]
                                                              params:params1
                                                            hasToken:NO
                                                          onResponse:^(HttpResponse *responseObject) {
                                                              NSDictionary* jsonDict = [responseObject jsonDist];
                                                              
                                                              if(jsonDict != nil)
                                                              {
                                                                  int state = [[jsonDict objectForKey:@"State"] intValue];
                                                                  
                                                                  if (state == 0)
                                                                  {
                                                                      [self showFailureAlertWithTitle:@"上传照片失败"];
                                                                  }
                                                              }
                                                              else
                                                              {
                                                                  [self showFailureAlertWithTitle:@"上传照片失败"];
                                                              }
                                                              
                                                          }
                                                             onError:^(HttpError *responseError) {
                                                             }];
                                         }
                                         //上传签名
                                         if (self.signImage !=nil)
                                         {
                                             NSMutableDictionary *params = [NSMutableDictionary dictionary];
                                             NSData *imageData =  UIImagePNGRepresentation(self.signImage);
                                             NSString *imageString = [imageData base64EncodedStringWithOptions:0];
                                             [params setObject:imageString forKey:@"Img"];
                                             [[HttpHelper instance] post:[NSString stringWithFormat:@"addsign&id=%@",self.idString]
                                                                  params:params
                                                                hasToken:NO
                                                              onResponse:^(HttpResponse *responseObject) {
                                                                  NSDictionary* jsonDict = [responseObject jsonDist];
                                                                  
                                                                  if(jsonDict != nil)
                                                                  {
                                                                      int state = [[jsonDict objectForKey:@"State"] intValue];
                                                                      
                                                                      if (state == 0)
                                                                      {
                                                                          [self showFailureAlertWithTitle:@"上传签名失败"];
                                                                      }
                                                                  }
                                                              }
                                                                 onError:^(HttpError *responseError) {
                                                                 }];
                                         }
                                         //上传建议
                                         if (self.suggestTextView.text !=nil)
                                         {
                                             NSMutableDictionary *params = [NSMutableDictionary dictionary];
                                             [params setObject:self.suggestTextView.text forKey:@"suggest"];
                                             [[HttpHelper instance] post:[NSString stringWithFormat:@"Updatesuggest&Id=%@",self.idString]
                                                                  params:params
                                                                hasToken:NO
                                                              onResponse:^(HttpResponse *responseObject) {
                                                                  NSDictionary* jsonDict = [responseObject jsonDist];
                                                                  
                                                                  if(jsonDict != nil)
                                                                  {
                                                                      int state = [[jsonDict objectForKey:@"State"] intValue];
                                                                      
                                                                      if (state == 0)
                                                                      {
                                                                          [self showFailureAlertWithTitle:@"上传建议失败"];
                                                                      }
                                                                  }
                                                              }
                                                                 onError:^(HttpError *responseError) {
                                                                 }];


                                         }
                                     });
                                 
                                 if (state == 1)
                                 {
                                     [self showSuccessAlertWithTitle:@"上传记录成功"];
                                 }
                             }
                         }
                            onError:^(HttpError *responseError) {
                                [self showFailureAlertWithTitle:@"上传记录失败"];
                                NSLog(@"error");
                            }];
    });
}
-(void)showSuccessAlertWithTitle:(NSString *)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:title];
        [SVProgressHUD dismissWithDelay:0.9];
    });
}
-(void)showFailureAlertWithTitle:(NSString *)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:title];
        [SVProgressHUD dismissWithDelay:0.9];
    });
}

/**
 *  按图片最大边成比例缩放图片
 *
 *  @param image   图片
 *  @param maxSize 图片的较长那一边目标缩到的(宽度／高度)
 *
 *  @return        等比缩放后的图片
 */
- (UIImage *)scaleImage:(UIImage *)image maxSize:(CGFloat)maxSize {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if(data.length < 200 * 1024){//0.25M-0.5M(当图片小于此范围不压缩)
        return image;
    }
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat targetWidth = imageWidth;
    CGFloat targetHeight = imageHeight;
    CGFloat imageMaxSize = MAX(imageWidth, imageHeight);
    if (imageMaxSize > maxSize) {
        CGFloat scale = 0;
        if (imageWidth >= imageHeight) {// 宽长
            scale = maxSize / imageWidth;
            targetWidth = maxSize;
            targetHeight = imageHeight * scale;
        } else { // 高长
            scale = maxSize / imageHeight;
            targetHeight = maxSize;
            targetWidth = imageWidth * scale;
        }
        UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
        [image drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaledImage;
    }
    return image;
}

- (IBAction)enterSuggest:(id)sender
{
    [sender removeFromSuperview];
    [self.suggestTextView becomeFirstResponder];
}
#pragma -mark sign
- (IBAction)sign:(id)sender
{
    BEPresentView *presentView = [[BEPresentView alloc ]init];
    ZWGraphicView *drawView = [[ZWGraphicView alloc]initWithFrame:CGRectMake(0,40, self.view.bounds.size.width, 350.0)];
    self.presentView = presentView;
    self.drawView = drawView;
    [presentView.contentView addSubview:self.drawView];
    [presentView showInView:self.view];
    
    UIButton *saveButton = [presentView.contentView viewWithTag:6666];
    UIButton *redrawButton = [presentView.contentView viewWithTag:5555];
    
    [saveButton addTarget:self action:@selector(saveSign:) forControlEvents:UIControlEventTouchDown];
    [redrawButton addTarget:self action:@selector(redraw:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)saveSign:(id)sender
{
    self.signImage = [self.drawView getDrawingImg];
    if (self.signImage)
    {
        self.signImageView.image = self.signImage;
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        [SVProgressHUD dismissWithDelay:0.9];
        [self.presentView disMissView];
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"保存失败，签名版上没有签名"];
        [SVProgressHUD dismissWithDelay:0.9];
    }
}
-(void)redraw:(id)sender
{
    [self.drawView clearDrawBoard];
}
#pragma -mark textViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
    //输入框编辑完成,视图恢复到原始状态
    self.view.frame = CGRectMake(0, 0, ScreenW, ScreenH);
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.suggestButton removeFromSuperview];
    CGRect frame = textView.frame;
    
    //（加上了输入中文选择文字的view高度）依据自己需求而定
    int offset = (frame.origin.y+130)-(ScreenH-216.0);//键盘高度216
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:0.30f];//动画持续时间
    
    if (offset>0) {
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -offset, ScreenW, ScreenH);
    }
    [UIView commitAnimations];
    
}
//回车时退出键盘
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    } 
    return YES; 
}
#pragma mark - 放大图片
-(void)scanBigImageClick1:(UITapGestureRecognizer *)tap
{
    
    UIImageView *clickedImageView = (UIImageView *)tap.view;
    [XWScanImage scanBigImageWithImageView:clickedImageView];
}


@end
