//
//  DetailViewController.m
//  AirWave
//
//  Created by Macmini on 2017/10/11.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "HttpClient.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "HttpError.h"
#import "HttpHelper.h"
#import "UIImage+Rotate.h"
#import "MyLabel.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
NSString *const TYPE = @"7681";
@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageResult;
@property (strong, nonatomic)NSString *idString;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet MyLabel *treatDateLabel;
@property (weak, nonatomic) IBOutlet MyLabel *treatWayLabel;
@property (weak, nonatomic) IBOutlet MyLabel *treatTimeLabel;
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30 , 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"upload_white"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(rightBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barButton;
    self.title = @"治疗结果";
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
   
    CGFloat width=[UIScreen mainScreen].bounds.size.width;
    CGFloat height=[UIScreen mainScreen].bounds.size.height;
    
    
    if (self.record.imagePath>0)
    {
         self.scrollView.contentSize = CGSizeMake(width, 1100);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(width, height);
    }
    self.treatDateLabel.text = [NSString stringWithFormat:@"  %@",self.record.dateString];
    self.treatWayLabel.text = [NSString stringWithFormat:@"  %@",self.record.treatWayString];
    self.treatTimeLabel.text = [NSString stringWithFormat:@"  %@",self.record.durationString];}
-(void)rightBarButtonClicked:(UIButton *)button
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    
    //上传数据
    [params setObject:@"jasper" forKey:@"Name"];
    [params setObject:@"男" forKey:@"Sex"];
    [params setObject:@"7" forKey:@"Age"];
    [params setObject:@"18819467352" forKey:@"Phone"];
    [params setObject:@"address" forKey:@"Address"];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[self.record.dateTime timeIntervalSince1970]];

    [params setObject:timeSp forKey:@"Date"];
    [params setObject:[NSString stringWithFormat:@"%d",(unsigned int)self.record.duration] forKey:@"Treattime"];
    [params setObject:[NSString stringWithFormat:@"%d",self.record.treatWay] forKey:@"Mode"];
    [params setObject:TYPE forKey:@"Type"];
    
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
                                     
                                     
                                     
                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                         [[HttpHelper instance] post:[NSString stringWithFormat:@"addimg&Id=%@",self.idString]
                                                              params:params1
                                                            hasToken:NO
                                                          onResponse:^(HttpResponse *responseObject) {
                                                              
                                                              NSDictionary* jsonDict = [responseObject jsonDist];
                                                              if(jsonDict != nil)
                                                              {
                                                                  int state = [[jsonDict objectForKey:@"State"] intValue];
                                                                  
                                                                  if (state == 1)
                                                                  {
                                                                      NSString *title = @"上传成功";
                                                                      UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                                                                                     message:nil
                                                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                                                                      //修改提示标题的颜色和大小
                                                                      NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:title];
                                                                      [titleAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, title.length)];
                                                                      [titleAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, title.length)];
                                                                      [alert setValue:titleAtt forKey:@"attributedTitle"];
                                                                      
                                                                      UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认"
                                                                                                                              style:UIAlertActionStyleDefault
                                                                                                                            handler:nil];
                                                                      [alert addAction:defaultAction];
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          [self presentViewController:alert animated:YES completion:nil];
                                                                      });
                                                                  }
                                                              }
                                                          }
                                                             onError:^(HttpError *responseError) {
                                                             }];
                                         
                                         
                                     });
                                 }
                                 if (state == 1)
                                 {
                                     NSString *title = @"上传成功";
                                     
                                     UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                                                    message:nil
                                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                     //修改提示标题的颜色和大小
                                     NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:title];
                                     [titleAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, title.length)];
                                     [titleAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, title.length)];
                                     [alert setValue:titleAtt forKey:@"attributedTitle"];
                                     
                                     UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认"
                                                                                             style:UIAlertActionStyleDefault
                                                                                           handler:nil];
                                     [alert addAction:defaultAction];
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self presentViewController:alert animated:YES completion:nil];
                                     });
                                 }
                             }
                         }
                            onError:^(HttpError *responseError) {
                            }];
    });
}
/**
 *  等比缩放成自定长宽的图片
 *
 *  @param image      源图片
 *  @param targetSize 自定义目标图片的size
 *
 *  @return 处理后图片
 */
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize
{
    UIGraphicsBeginImageContext(CGSizeMake(targetSize.width, targetSize.height));
    [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *targetSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return targetSizeImage;
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


@end
