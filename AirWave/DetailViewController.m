//
//  DetailViewController.m
//  AirWave
//
//  Created by Macmini on 2017/10/11.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "RecordReportViewController.h"
#import "HttpClient.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "HttpError.h"
#import "HttpHelper.h"
#import "UIImage+Rotate.h"
#import "MyLabel.h"
#import "SVProgressHUD.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
static NSString *AIRWAVETYPE = @"7681";
static NSString *BLOODDEVTYPE = @"8888";
NSString *const TYPE = @"7681";
@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageResult;
@property (strong, nonatomic)NSString *idString;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet MyLabel *treatDateLabel;
@property (weak, nonatomic) IBOutlet MyLabel *treatWayLabel;
@property (weak, nonatomic) IBOutlet MyLabel *treatTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeOrLevelLabel;
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"治疗结果";

    CGFloat width=[UIScreen mainScreen].bounds.size.width;
    CGFloat height=[UIScreen mainScreen].bounds.size.height;
    if (self.record.imagePath>0)
    {
         self.scrollView.contentSize = CGSizeMake(width, 1100);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *imagePath = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",self.record.idString]];
            self.record.imagePath = imagePath;
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                _imageResult.contentMode = UIViewContentModeScaleAspectFit;
                _imageResult.image = [image rotate:UIImageOrientationRight];
            });
        });
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(width, height);
    }
    self.treatDateLabel.text = [NSString stringWithFormat:@"  %@",self.record.dateString];
    
    if ([self.record.type isEqualToString:BLOODDEVTYPE])
    {
        self.modeOrLevelLabel.text = @"治疗强度";
        self.treatWayLabel.text = [NSString stringWithFormat:@"  %d",self.record.treatWay];
    }else if([self.record.type isEqualToString:AIRWAVETYPE]){
        self.treatWayLabel.text = [NSString stringWithFormat:@"  %@",self.record.treatWayString];
    }
    self.treatTimeLabel.text = [NSString stringWithFormat:@"  %@",self.record.durationString];
    self.nameLabel.text = [NSString stringWithFormat:@"  %@",self.record.name];
    self.sexLabel.text = [NSString stringWithFormat:@"  %@",self.record.sex];
    self.ageLabel.text = [NSString stringWithFormat:@"  %@",self.record.age];
    self.phoneLabel.text = [NSString stringWithFormat:@"  %@",self.record.phoneNumber];
    self.addressLabel.text = [NSString stringWithFormat:@"  %@",self.record.address];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CreateReport"])
    {
        RecordReportViewController *vc = (RecordReportViewController *)segue.destinationViewController;
        vc.record = self.record;
    }
}


@end
